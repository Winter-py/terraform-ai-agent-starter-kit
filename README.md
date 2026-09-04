# terraform-copilot-agent-starter-kit

Multi-agent orchestration templates, delegation patterns, and agent definitions for AI coding agents managing infrastructure with Terraform.

## Included starter templates

```text
templates/
├── agents/
│   ├── terraform-orchestrator.yaml
│   └── terraform-specialists.yaml
├── delegation/
│   └── terraform-delegation-patterns.yaml
└── orchestration/
    └── terraform-change-lifecycle.yaml
```

## What each template provides

- **Agent definitions**: coordinator + specialist agents for planning, review, and apply flows.
- **Orchestration workflow**: a staged Terraform change lifecycle from intake through closure.
- **Delegation patterns**: reusable routing/sequence patterns for plan-before-apply, drift handling, and safe remediation loops.

## Usage

1. Copy the template files into your agent runtime/config repository.
2. Rename agent identifiers as needed for your platform.
3. Map each stage/delegation step to your execution environment (CLI runner, CI job, or hosted agent).
4. Enforce guardrails before apply actions (policy/security approval).
5. Copy and adapt [.github/copilot-instructions.md](.github/copilot-instructions.md) (below) so
   your repo's own conventions and guardrails, not just this starter kit's, are on record.

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
