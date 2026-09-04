# Project conventions for Copilot

This repository is a **starter kit**, not a live deployment. It ships YAML templates that
define multi-agent orchestration for Terraform work: agent definitions, a change lifecycle
workflow, and delegation patterns. There is no Terraform state, no backend, and no cloud
credentials here — nothing in this repo should ever run `terraform apply` against real
infrastructure.

## Repository layout

```text
templates/
├── agents/          # agent definitions (coordinator + specialists)
├── delegation/      # reusable routing/sequence patterns
└── orchestration/   # staged change lifecycle workflows
```

## Editing the templates

- Templates are **YAML only**. Two-space indent, lowercase `snake_case` keys, no tabs.
- Agent and pattern names are `kebab-case` and prefixed by domain: `terraform-plan`,
  `terraform-review`, `terraform-apply`, `plan-before-apply`.
- Names are contracts. `terraform-orchestrator.yaml` routes to specialists by name, the
  lifecycle stages `delegate_to` them, and delegation patterns list them in `sequence`.
  Renaming an agent means updating every reference in `templates/` and the README tree.
- Artifact names are contracts too — `plan_summary`, `risk_notes`, `review_findings`,
  `approval_recommendation`, `apply_log_summary`, `changed_resources`. A stage that
  `requires` an artifact must be downstream of the agent that declares it in `artifacts`.
- Keep templates runtime-agnostic. No vendor-specific SDK fields, no hardcoded account IDs,
  regions, role ARNs, workspace names, or repository URLs — use placeholders and document
  them.
- New templates go in the matching subdirectory and get added to the README tree and the
  "What each template provides" list in the same change.

## Terraform guardrails the templates must preserve

These are the point of the kit — do not weaken them to simplify a template:

- **Plan before apply, always.** Every path that reaches `terraform-apply` passes through
  `terraform-plan` then `terraform-review` first.
- **Apply is gated on explicit approval.** Any execution stage keeps a guardrail equivalent
  to `review_findings.approval_recommendation == "approve"`. Never add an apply route that
  bypasses review.
- **Applies run against a saved plan file**, not a re-planned target — the reviewed plan is
  the approved artifact.
- **Partial failures escalate, they don't auto-retry.** Remediation goes back through the
  `safe-remediation-loop` sequence (apply → plan → review → apply), not a bare re-apply.
- **State is never edited casually.** `terraform state rm`, `terraform import`,
  `-target`, `-replace`, and `-auto-approve` are human-approved operations; a template may
  propose them but must never route them as an autonomous step.
- Secrets stay out of variables, outputs, examples, and plan summaries. Plan output can leak
  values — summaries must describe resource changes, not dump raw plan text.

## Terraform code conventions (for HCL this kit's agents generate or review)

- Format with `terraform fmt`; validate with `terraform validate` before proposing a plan.
- Pin provider versions with `required_providers` and constrain `required_version`.
  Prefer `~>` over unbounded ranges.
- Resource and variable names are `snake_case`; don't repeat the resource type in the name
  (`aws_s3_bucket.logs`, not `aws_s3_bucket.logs_bucket`).
- Every variable gets a `type` and a `description`; every output gets a `description` and
  `sensitive = true` where warranted.
- Prefer `for_each` over `count` for named sets, so an insertion doesn't re-index the world.
- Modules take inputs and return outputs — no provider blocks or backend config inside a
  reusable module.

## Pull request etiquette

- Title format: `<area>: <imperative summary>` (e.g., `delegation: add drift triage pattern`).
  Use the template directory as the area: `agents`, `delegation`, `orchestration`, `docs`.
- PR body must include a "Why" section before any "What" section.
- Link an issue or skip linking entirely — don't fake-link.
- Call out any change to a guardrail, an agent name, or an artifact name explicitly in the
  body; those are breaking changes for anyone who has copied the templates.

## Tools to avoid

- Do not run `terraform init`, `plan`, `apply`, or `destroy` from this repo — there is no
  configuration to act on and no credentials should be present.
- Do not call external network APIs unless explicitly listed in
  `.github/mcp-allowlist.yml`. That file is default-deny; if a server isn't in
  `allowed_servers`, treat it as unreachable rather than asking for an exception.
