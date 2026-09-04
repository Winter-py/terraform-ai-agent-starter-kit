# Plan → Act → Evaluate

This kit uses the same three-stage shape everywhere an agent acts on its own: write a
structured plan before touching anything, act within that plan's declared scope, then
evaluate and record what happened before anything downstream can rely on it. Two concrete
instances of it live in this repo.

## The generic shape

```mermaid
flowchart LR
    Plan["📋 Plan<br/>Write a structured plan<br/>before acting"]
    Act["⚙️ Act<br/>Execute within the<br/>plan's declared scope"]
    Evaluate["✅ Evaluate<br/>Record outcome + reasoning,<br/>gate what happens next"]

    Plan --> Act --> Evaluate
    Evaluate -. "escalate / re-plan on failure" .-> Plan
```

## Instance 1: Terraform change lifecycle

[`templates/orchestration/terraform-change-lifecycle.yaml`](templates/orchestration/terraform-change-lifecycle.yaml),
executed by the agents in [`templates/agents/`](templates/agents/).

```mermaid
flowchart TD
    Intake["intake<br/>capture_scope<br/>→ normalized_request"]

    subgraph PLAN["PLAN"]
      Planning["planning<br/>delegate_to: terraform-plan<br/>→ plan_summary"]
    end

    subgraph ACT["ACT — gated"]
      Review["review<br/>delegate_to: terraform-review<br/>→ review_findings"]
      Gate{"review_findings.<br/>approval_recommendation<br/>== 'approve' ?"}
      Execution["execution<br/>delegate_to: terraform-apply<br/>(saved plan file, not a re-plan)<br/>→ apply_log_summary"]
    end

    subgraph EVALUATE["EVALUATE"]
      Closure["closure<br/>publish_final_summary"]
    end

    Remediate["safe-remediation-loop<br/>(delegation pattern)"]

    Intake --> Planning --> Review --> Gate
    Gate -- "approve" --> Execution --> Closure
    Gate -- "reject" --> Remediate
    Remediate --> Planning
```

Guardrails this preserves (from
[`.github/copilot-instructions.md`](.github/copilot-instructions.md)):

- **Plan before apply, always** — `execution` requires both `plan_summary` and
  `review_findings`; there's no route that skips straight to apply.
- **Apply is gated on explicit approval** — the `Gate` diamond, not a silent pass-through.
- **Applies run against the saved plan file**, not a re-planned target.
- **Partial failures escalate**, they don't auto-retry — a rejected/failed run re-enters
  through `safe-remediation-loop` (plan → review → apply again), never a bare re-apply.

## Instance 2: Issue triage

[`.github/workflows/agent-triage.yml`](.github/workflows/agent-triage.yml) — the same shape
applied to this repo's own issues instead of Terraform changes.

```mermaid
flowchart TD
    Trigger["issue opened/labeled<br/>needs-triage"]

    subgraph PLAN["PLAN"]
      WritePlan["Produce structured plan<br/>→ plan.md artifact"]
    end

    subgraph ACT["ACT"]
      Guardrail{"mentions auto-approve /<br/>state rm / bypassed review?"}
      Scope{"describes a real<br/>Terraform run?"}
      Categorize["Label by template area<br/>+ issue type"]
      FlagRisk["Label: guardrail-risk<br/>(needs a maintainer)"]
      FlagScope["Label: out-of-scope<br/>(no real backend/state here)"]
    end

    subgraph EVALUATE["EVALUATE"]
      Comment["Comment: labels applied +<br/>reasoning + plan artifact link"]
    end

    Trigger --> WritePlan --> Guardrail
    Guardrail -- "yes" --> FlagRisk --> Comment
    Guardrail -- "no" --> Scope
    Scope -- "yes" --> FlagScope --> Comment
    Scope -- "no" --> Categorize --> Comment
```

## Why the shape repeats

A plan artifact before every action and a recorded evaluation after every action bounds an
agent's blast radius and makes it reviewable, regardless of what it's actually doing —
changing infrastructure or triaging issues on the kit itself. See
[`.github/copilot-instructions.md`](.github/copilot-instructions.md) for the guardrails this
protects, and [`README.md`](README.md) for how each workflow maps onto `templates/`.
