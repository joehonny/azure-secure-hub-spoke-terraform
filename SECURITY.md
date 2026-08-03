# Security Policy

## Scope and support

This repository is a reference-only Terraform architecture. It is not a deployed production environment and does not include operational support, security monitoring, or a service-level commitment. Only the current default branch is maintained.

The NSGs and route tables are structural reference components. They intentionally contain no custom security rules or routes and must not be treated as production segmentation or routing policy.

## Report a vulnerability

Use GitHub private vulnerability reporting from the repository **Security** tab when it is available. If it is unavailable, contact the repository owner privately through the verified GitHub profile before disclosing technical details. Do not open a public issue containing exploit details, credentials, tenant data, subscription IDs, state files, or other sensitive information.

Include:

- The affected file and commit.
- A concise impact statement and reproduction that does not contact an Azure subscription.
- Suggested remediation, if known.
- Whether the issue could expose credentials, Terraform state, or cloud resources.

You should receive an acknowledgment when the repository owner reviews the report. No response-time commitment is implied.

## Secrets and cloud access

Never commit Terraform state, variable files containing environment values, credentials, client secrets, private keys, authentication caches, tenant data, or subscription IDs. Pull requests must be testable with backend-disabled initialization and without Azure authentication, planning, applying, or deployment.
