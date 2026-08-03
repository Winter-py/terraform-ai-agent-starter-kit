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
