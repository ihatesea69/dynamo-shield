# Fine-Grained Access Control for Amazon DynamoDB

[![Terraform Validate](https://github.com/ihatesea69/dynamo-shield/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/ihatesea69/dynamo-shield/actions/workflows/terraform-validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Terraform implementation of [Fine-Grained Access Control for Amazon DynamoDB](https://aws.amazon.com/blogs/aws/fine-grained-access-control-for-amazon-dynamodb/) -- enabling mobile and web apps to access DynamoDB **directly**, without a proxy tier, by delegating authorization to IAM policy conditions.

---

## The Problem

Traditional mobile/gaming apps using a shared DynamoDB table required a **proxy server** solely to enforce per-user access:

```
App  ->  Proxy  ->  DynamoDB
          ^ added latency, cost, ops burden
```

## The Solution

AWS IAM **Condition** keys allow you to restrict DynamoDB access at the row and attribute level. Apps call DynamoDB directly using short-lived credentials from AWS STS:

```
App  ->  STS (AssumeRoleWithWebIdentity)  ->  DynamoDB
                    IAM enforces FGAC inline --+
```

---

## What This Repo Provides

| Layer | Description |
|-------|-------------|
| **DynamoDB module** | `GameScores` table with composite key, GSI, encryption, PITR |
| **IAM module** | Web Identity role + four FGAC policy types |
| **Policy templates** | Standalone JSON policies in `policies/` |
| **Example** | Ready-to-run example in `examples/game_scores/` |
| **CI/CD** | GitHub Actions for `terraform validate` and `terraform plan` |
| **Docs** | Architecture overview and integration guide |

---

## Repository Structure

```
.
+-- .github/
|   +-- workflows/
|       +-- terraform-validate.yml   # Runs on every push -- fmt + validate
|       +-- terraform-plan.yml       # Runs on PRs to main -- plan + comment
+-- docs/
|   +-- architecture.md              # Architecture diagram and component reference
|   +-- usage.md                     # Step-by-step deployment and SDK integration
+-- examples/
|   +-- game_scores/
|       +-- main.tf                  # Standalone runnable example
|       +-- README.md
+-- policies/
|   +-- horizontal_access.json       # Row-level access (leading key match)
|   +-- vertical_access.json         # Attribute-level access
|   +-- combined_access.json         # Row + attribute restrictions
|   +-- read_only_access.json        # Read-only, row-scoped
+-- terraform/
|   +-- main.tf                      # Root module
|   +-- providers.tf                 # AWS provider + Terraform version
|   +-- variables.tf                 # All input variables
|   +-- outputs.tf                   # Table ARN, role ARN, policy ARN
|   +-- example.tfvars               # Copy -> terraform.tfvars and customise
|   +-- modules/
|       +-- dynamodb/                # DynamoDB table resource
|       +-- iam/                     # IAM role + policy resources
+-- .gitignore
+-- CONTRIBUTING.md
+-- README.md
```

---

## Fine-Grained Access Policy Types

### Horizontal (Row-Level)
Each authenticated user can only access **their own rows** using `dynamodb:LeadingKeys`:

```json
"Condition": {
  "ForAllValues:StringEquals": {
    "dynamodb:LeadingKeys": ["${cognito-identity.amazonaws.com:sub}"]
  }
}
```

### Vertical (Attribute-Level)
All users can access all rows, but only **specific attributes** are exposed using `dynamodb:Attributes`:

```json
"Condition": {
  "ForAllValues:StringEquals": {
    "dynamodb:Attributes": ["UserId", "GameTitle", "Score", "Wins", "Losses"]
  }
}
```

### Combined (Default)
Both row-level and attribute-level restrictions applied together.

### Read-Only
Like horizontal, but allows only `GetItem`, `BatchGetItem`, and `Query`.

---

## Quick Start

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configured
- An AWS account with IAM permissions to create DynamoDB tables and IAM roles

### Deploy

```bash
# Clone
git clone https://github.com/ihatesea69/dynamo-shield.git
cd dynamo-shield/terraform

# Configure
cp example.tfvars terraform.tfvars
# Edit terraform.tfvars with your Cognito Identity Pool ID and preferences

# Deploy
terraform init
terraform plan
terraform apply
```

### Outputs

```
dynamodb_table_name = "GameScores"
dynamodb_table_arn  = "arn:aws:dynamodb:us-east-1:123456789012:table/GameScores"
iam_role_arn        = "arn:aws:iam::123456789012:role/dynamodb-fgac-dev-dynamodb-fgac-role"
iam_policy_arn      = "arn:aws:iam::123456789012:policy/dynamodb-fgac-dev-dynamodb-fgac-policy"
```

---

## DynamoDB Table Schema

| Attribute   | Type   | Key Role          |
|-------------|--------|-------------------|
| `UserId`    | String | Hash key (PK)     |
| `GameTitle` | String | Range key (SK)    |
| `Score`     | Number | GSI sort key      |
| `Wins`      | Number | Data attribute    |
| `Losses`    | Number | Data attribute    |

**GSI** -- `GameTitleIndex` (hash: `GameTitle`, sort: `Score`): enables global leaderboard queries per game.

---

## GitHub Actions Setup

For the **Terraform Plan** workflow to work on PRs, add these repository secrets:

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM user key with DynamoDB + IAM permissions |
| `AWS_SECRET_ACCESS_KEY` | Corresponding secret |
| `AWS_REGION` | Target region (optional, defaults to `us-east-1`) |

---

## Documentation

- [Architecture Overview](docs/architecture.md)
- [Usage Guide & SDK Integration](docs/usage.md)
- [Example: Game Scores](examples/game_scores/README.md)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

MIT -- see [LICENSE](LICENSE).

---

## References

- [AWS Blog: Fine-Grained Access Control for Amazon DynamoDB](https://aws.amazon.com/blogs/aws/fine-grained-access-control-for-amazon-dynamodb/)
- [DynamoDB Developer Guide: Fine-Grained Access Control](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/specifying-conditions.html)
- [IAM Condition Keys for DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/specifying-conditions.html#FGAC_DDB.ConditionKeys)
- [STS AssumeRoleWithWebIdentity](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html)
