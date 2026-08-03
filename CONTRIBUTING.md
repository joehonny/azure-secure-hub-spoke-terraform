# Contributing

Thank you for improving this Azure hub-and-spoke Terraform reference.

## Safety boundary

All repository configurations and examples are reference-only. They are not deployed production environments. Contributions must not require an Azure login, credentials, subscription ID, remote backend, plan, apply, deployment, or billable cloud call.

Do not commit Terraform state, `.tfvars` environment data, exported cloud configuration, authentication caches, or secrets. Use documentation-safe placeholder names and RFC 1918 address ranges.

## Development workflow

1. Create a focused branch or isolated worktree.
2. Keep module inputs and outputs stable unless the change explicitly updates and tests the contract.
3. Format and validate the root module and reference-only example.
4. Run the Terraform tests, TFLint, and Trivy configuration scan.
5. Review the diff for secrets, subscription IDs, backends, unsafe permissions, and unintended resource types.

```powershell
terraform fmt -recursive
terraform init -backend=false -input=false
terraform validate -no-color
terraform test -no-color
terraform -chdir=examples/basic init -backend=false -input=false
terraform -chdir=examples/basic validate -no-color
tflint --init --config "$PWD/.tflint.hcl"
tflint --config "$PWD/.tflint.hcl" --format compact
trivy config --severity HIGH,CRITICAL --exit-code 1 --skip-dirs .terraform --skip-dirs .tools .
```

## Pull requests

A pull request should explain the reference behavior changed, security and cost implications, verification performed, skipped live checks, and any remaining uncertainty. Do not include deployment or customer claims without reproducible evidence. GitHub Action dependencies must use full 40-character commit SHAs with readable version comments.

Changes that turn structural NSGs or route tables into policy must include explicit requirements and tests for every intended flow or route. Production adoption still requires an independent architecture, security, identity, cost, compliance, and operations review.
