# Example environment: `aws-eu-west-2`

A minimal, deliberately toy AWS environment — one S3 bucket — showing the shape of HCL
the templates in [`templates/`](../../templates/) are meant to plan, review, and apply
against. This is not a real environment:

- The backend is `local`, so cloning this repo never points at anyone's real state.
- There are no credentials, account IDs, or regions here that point at anything live.
- `terraform init`/`plan` will run if you have the AWS provider available, but there's
  nothing here worth actually applying.

## Using this as a starting point

To turn this into a real environment:

1. Swap the `backend "local"` block in [`terraform.tf`](terraform.tf) for a remote
   backend (S3, Azure Blob, GCS, ...).
2. Fill in real values for the variables in [`variables.tf`](variables.tf) — via
   `.tfvars`, not by editing defaults in place.
3. Route changes through the `terraform-plan` → `terraform-review` → `terraform-apply`
   agents in [`templates/agents/`](../../templates/agents/), gated by
   [`templates/orchestration/terraform-change-lifecycle.yaml`](../../templates/orchestration/terraform-change-lifecycle.yaml)
   — not by running `terraform apply` directly from a laptop.

See [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md) for the
HCL conventions and guardrails this example follows.
