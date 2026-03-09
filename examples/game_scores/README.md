# Game Scores Example

This example deploys a `GameScores` DynamoDB table with **combined** fine-grained access control — each authenticated user can only read and write their own items, restricted to a defined set of attributes.

## What Gets Created

| Resource | Description |
|---|---|
| `aws_dynamodb_table.game_scores` | GameScores table with UserId (hash) + GameTitle (range) + GSI on GameTitle/Score |
| `aws_iam_role.dynamodb_fgac` | IAM Role assumed via Cognito Web Identity |
| `aws_iam_policy.dynamodb_fgac` | Combined FGAC policy (horizontal + vertical) |
| `aws_iam_role_policy_attachment` | Attaches the policy to the role |

## Prerequisites

- Terraform >= 1.5
- AWS credentials configured (`aws configure` or environment variables)
- An existing Cognito Identity Pool (or leave blank for testing)

## Usage

```bash
# 1. Initialise
terraform init

# 2. Preview changes
terraform plan

# 3. Apply
terraform apply
```

## Customisation

Change `access_policy_type` in `main.tf` to one of:

| Value | Description |
|---|---|
| `horizontal` | Users access only their own rows (leading key match) |
| `vertical` | All users can access, but only specific attributes |
| `combined` | Both row-level and attribute-level restrictions |
| `read_only` | Read-only access to a user's own rows |

## Clean Up

```bash
terraform destroy
```
