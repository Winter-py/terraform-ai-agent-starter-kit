# terraform-copilot-agent-starter-kit

Multi-agent orchestration templates, delegation patterns, and agent definitions for AI coding agents managing infrastructure with Terraform.

## Included starter templates

```text
.github/
├── copilot-instructions.md
├── mcp-allowlist.yml
└── workflows/
    └── agent-triage.yml
templates/
├── agents/
│   ├── terraform-orchestrator.yaml
│   └── terraform-specialists.yaml
├── delegation/
│   └── terraform-delegation-patterns.yaml
└── orchestration/
    └── terraform-change-lifecycle.yaml
examples/
└── aws-eu-west-2/
    ├── terraform.tf
    ├── variables.tf
    ├── main.tf
    └── outputs.tf
```

## What each template provides

- **Agent definitions**: coordinator + specialist agents for planning, review, and apply flows.
- **Orchestration workflow**: a staged Terraform change lifecycle from intake through closure.
- **Delegation patterns**: reusable routing/sequence patterns for plan-before-apply, drift handling, and safe remediation loops.
- **Example environment**: a toy, local-backend AWS environment
  ([examples/aws-eu-west-2/](examples/aws-eu-west-2/)) so the templates above have real HCL
  to plan/review/apply against instead of staying purely abstract.

## Usage

1. Copy the template files into your agent runtime/config repository.
2. Rename agent identifiers as needed for your platform.
3. Map each stage/delegation step to your execution environment (CLI runner, CI job, or hosted agent).
4. Enforce guardrails before apply actions (policy/security approval).
5. Copy and adapt [.github/copilot-instructions.md](.github/copilot-instructions.md) (below) so
   your repo's own conventions and guardrails, not just this starter kit's, are on record.
6. Configure branch protection on `main` (see below) — [.github/CODEOWNERS](.github/CODEOWNERS)
   and [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md) don't enforce
   anything on their own until required reviews are turned on.

## Repo settings: branch protection

CODEOWNERS only blocks a merge if the repo is configured to require code owner review.
Without this step it's just documentation. Requires `gh` authenticated as a repo admin:

```powershell
# 1. Get the current repo name
$repo = gh repo view --json nameWithOwner -q .nameWithOwner

# 2. Require PR review + code owner review before merging to main
$body = @'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "require_code_owner_reviews": true
  },
  "restrictions": null
}
'@
$body | gh api -X PUT "repos/$repo/branches/main/protection" --input -
```

- `require_code_owner_reviews: true` is what makes [.github/CODEOWNERS](.github/CODEOWNERS)
  actually gate merges to `templates/agents/`, `templates/orchestration/`,
  `.github/workflows/`, and the other paths it lists — mirroring the plan-before-apply,
  approval-gated pattern this kit encodes for Terraform changes, applied to changes on the
  kit itself.
- `enforce_admins: false` lets repo admins bypass the rule; set it to `true` if you want the
  guardrail to apply to admins too, including you.
- Re-run this after renaming the default branch or changing the required review count —
  the API call isn't idempotent against config drift, it just sets the state each time.

## Repo settings: environments (for `deploy.yml`)

[.github/workflows/deploy.yml](.github/workflows/deploy.yml) gates on `environment:
production`. That name has to exist as a **GitHub Environment** under repo Settings →
Environments — it's a GitHub feature, unrelated to anything in `Terraform/`, and nothing
creates it automatically. Until it exists, dispatching the workflow fails with something
like "Value 'production' is not valid."

```powershell
# 1. Get the current repo name
$repo = gh repo view --json nameWithOwner -q .nameWithOwner

# 2. Create the "production" environment
gh api -X PUT "repos/$repo/environments/production" | Out-Null

# 3. Require a human reviewer before the environment can be used — the deploy-side
#    equivalent of the review_findings.approval_recommendation == "approve" gate this
#    kit puts in front of terraform-apply
$reviewerId = gh api users/your-username --jq .id
$body = @"
{
  "reviewers": [
    { "type": "User", "id": $reviewerId }
  ],
  "deployment_branch_policy": {
    "protected_branches": false,
    "custom_branch_policies": true
  }
}
"@
$body | gh api -X PUT "repos/$repo/environments/production" --input -

# 4. Restrict deploys to the main branch
$branchBody = @'
{ "name": "main" }
'@
$branchBody | gh api -X POST "repos/$repo/environments/production/deployment-branch-policies" --input -
```

- Replace `your-username` with whoever (or use `"type": "Team"` with a team id instead)
  should approve production deploys.
- Repeat for any other environment name a workflow references — e.g. if
  `Terraform/AWS/enviroment/` grows a `staging` region, give it its own environment and
  reviewer set rather than reusing `production`'s.

## Agent memory: `.github/copilot-instructions.md` / `AGENTS.md`

Chat context resets every session. A file in the repo doesn't. This kit treats
[.github/copilot-instructions.md](.github/copilot-instructions.md) as the **canonical,
version-controlled surface for long-term project memory** — the place an agent reads
guardrails and conventions from at the start of every session, instead of relying on
whatever happened to be said in a previous conversation.

- **Two conventions, same role.** `.github/copilot-instructions.md` is GitHub Copilot's
  native path; `AGENTS.md` at the repo root is the emerging cross-tool convention several
  other coding agents read the same way. Pick whichever your agent(s) support — or keep
  both, with one a thin pointer to the other — but keep exactly one as the source of truth
  so the guardrails can't drift apart.
- **What belongs there:** durable, repo-wide facts an agent should never have to be told
  twice — naming contracts between files, the plan-before-apply and approval-gate
  guardrails, state-mutation rules, HCL conventions. Anything that would still be true next
  quarter.
- **What doesn't:** in-progress task state, a specific PR's context, anything that's true
  today but not structurally — that belongs in the PR/issue, not in agent memory.
- **Why it matters for Terraform specifically:** the riskiest agent mistakes here are the
  ones config alone won't catch — applying without review, retrying a failed apply instead
  of re-planning, editing state directly. Putting those guardrails in a file every agent
  loads automatically closes that gap independent of which agent runtime is in use.
- **This repo is itself an example.** The templates define how orchestrator/specialist
  agents delegate Terraform work to each other; `.github/copilot-instructions.md` applies
  the same idea one level up — encoding this repo's own guardrails as memory for whatever
  agent is editing the templates. When you copy the templates into your own repository,
  copy and rewrite this file too so it reflects *your* Terraform conventions, not this
  starter kit's.

## Tool access: `.github/mcp-allowlist.yml`

`.github/copilot-instructions.md` tells an agent what it may *do*; this file tells it what
it may *reach*. [.github/mcp-allowlist.yml](.github/mcp-allowlist.yml) is a default-deny list
of MCP servers agents are permitted to call in this repo — anything not explicitly listed is
denied.

- Keep it scoped to what the Terraform workflow actually needs: registry/provider docs,
  cloud provider documentation search, and read/comment access to GitHub for the review
  stage. Deny everything else, especially:
  - filesystem servers with access to `*.tfstate` or `*.tfvars` (state and vars can hold
    secrets in plaintext)
  - anything with shell/exec capability (an unreviewed path to `apply`)
  - servers that can reach cloud provider APIs directly, bypassing `terraform plan`/`apply`
- Server names in the file must match how each server is registered in your agent runtime's
  MCP config — rename the entries to fit your setup rather than assuming the ones shipped
  here resolve to anything.
- Update this file and `.github/copilot-instructions.md` together: the allowlist enforces
  the boundary the instructions file states in prose ("do not call external network APIs
  unless explicitly listed here").

## Example automation: `.github/workflows/agent-triage.yml`

A worked example of the plan/act/evaluate shape applied to issue triage on this repo
itself, rather than to Terraform changes. It fires on issues labeled `needs-triage` and:

1. **Plans**: writes a triage plan to an uploaded artifact before touching anything.
2. **Acts**: routes the issue based on this repo's own scope and guardrails, not generic
   bug/feature/question buckets — flags guardrail-sensitive asks (`auto-approve`, state
   edits, bypassed review) for a maintainer instead of auto-labeling, flags issues about a
   real Terraform run as out of scope (this kit has no backend, state, or credentials to
   reproduce that against), and otherwise labels by template area (`templates/agents`,
   `templates/delegation`, `templates/orchestration`) plus issue type.
3. **Evaluates**: comments back on the issue with the labels applied and the reasoning, and
   links the plan artifact and workflow run for traceability.

It expects these labels to already exist on the repo — `gh issue edit --add-label` errors
on a label that doesn't exist, it won't create one: `needs-triage` (the trigger),
`guardrail-risk`, `out-of-scope`, `area/agents`, `area/delegation`, `area/orchestration`,
`area/docs`, `bug`, `enhancement`, `question`.
