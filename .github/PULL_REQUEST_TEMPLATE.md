<!-- Title format: <area>: <imperative summary>, e.g. "delegation: add drift triage pattern" -->

## Why
<!-- The motivation for this change. Required, and comes before What. -->

## What
<!-- Concrete changes made. -->

## Area
<!-- Should match the area in the PR title. -->
- [ ] agents
- [ ] delegation
- [ ] orchestration
- [ ] docs

## Linked issue
<!-- Closes #123, or "No linked issue" — don't fake-link one that isn't related. -->

## Guardrail / contract impact
<!-- Does this rename an agent, rename or add an artifact (plan_summary, risk_notes,
     review_findings, approval_recommendation, apply_log_summary, changed_resources), or
     touch a guardrail (plan-before-apply, the approval gate, state-mutation rules)? Call
     it out explicitly — these are breaking changes for anyone who copied the templates. -->
- [ ] No guardrail, agent-name, or artifact-name change
- [ ] Changes one of the above — described above, with every reference updated across
      `templates/`, the README tree, and any downstream stage that `requires`/`delegate_to`s it

## Checklist

- [ ] YAML: two-space indent, `snake_case` keys, no tabs
- [ ] Agent/pattern names are `kebab-case`, domain-prefixed (`terraform-plan`, `terraform-review`, …)
- [ ] No vendor-specific fields, hardcoded account IDs, regions, role ARNs, or workspace names
- [ ] Every path to `terraform-apply` still passes through `terraform-plan` → `terraform-review`
- [ ] Apply stages still gate on `review_findings.approval_recommendation == "approve"`
- [ ] New templates added to the README tree and "What each template provides" list
