# Usage Guide

## Prerequisites

| Tool | Minimum Version | Install |
|------|----------------|---------|
| Terraform | 1.5.0 | [Download](https://developer.hashicorp.com/terraform/downloads) |
| AWS CLI | 2.x | [Install](https://aws.amazon.com/cli/) |
| Git | 2.x | [Install](https://git-scm.com/) |

## 1. Clone and Configure

```bash
git clone https://github.com/<your-org>/dynamodb-fine-grained-access-control.git
cd dynamodb-fine-grained-access-control
```

Configure AWS credentials:

```bash
aws configure
# or
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
```

## 2. Customise Variables

Copy the example vars file and edit it:

```bash
cp terraform/example.tfvars terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars`:

```hcl
aws_region               = "us-east-1"
project_name             = "my-game-app"
environment              = "dev"
table_name               = "GameScores"
billing_mode             = "PAY_PER_REQUEST"
cognito_identity_pool_id = "us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
access_policy_type       = "combined"
```

## 3. Deploy

```bash
cd terraform

terraform init
terraform plan
terraform apply
```

Expected output:
```
Apply complete! Resources: 4 added.

Outputs:
  dynamodb_table_arn  = "arn:aws:dynamodb:us-east-1:123456789012:table/GameScores"
  dynamodb_table_name = "GameScores"
  iam_role_arn        = "arn:aws:iam::123456789012:role/my-game-app-dev-dynamodb-fgac-role"
  iam_policy_arn      = "arn:aws:iam::123456789012:policy/my-game-app-dev-dynamodb-fgac-policy"
```

## 4. Integrate in Your App

### JavaScript / AWS SDK v3

```javascript
import { CognitoIdentityClient } from "@aws-sdk/client-cognito-identity";
import { fromCognitoIdentityPool } from "@aws-sdk/credential-providers";
import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

const identityPoolId = "us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
const roleArn = "<iam_role_arn from terraform output>";

// Exchange Cognito token for temporary DynamoDB credentials
const client = new DynamoDBClient({
  region: "us-east-1",
  credentials: fromCognitoIdentityPool({
    clientConfig: { region: "us-east-1" },
    identityPoolId,
    logins: {
      "cognito-idp.us-east-1.amazonaws.com/<USER_POOL_ID>": idToken,
    },
  }),
});

// The IAM policy automatically restricts this to the logged-in user's items
const response = await client.send(new GetItemCommand({
  TableName: "GameScores",
  Key: {
    UserId:    { S: currentUserId },
    GameTitle: { S: "SpaceInvaders" },
  },
}));
```

### Python / boto3

```python
import boto3

# Obtain credentials via Cognito Identity
cognito = boto3.client("cognito-identity", region_name="us-east-1")
identity_id = cognito.get_id(
    IdentityPoolId="us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    Logins={"cognito-idp.us-east-1.amazonaws.com/<USER_POOL_ID>": id_token},
)["IdentityId"]

credentials = cognito.get_credentials_for_identity(
    IdentityId=identity_id,
    Logins={"cognito-idp.us-east-1.amazonaws.com/<USER_POOL_ID>": id_token},
)["Credentials"]

# Build a DynamoDB client using the temporary credentials
dynamo = boto3.client(
    "dynamodb",
    region_name="us-east-1",
    aws_access_key_id=credentials["AccessKeyId"],
    aws_secret_access_key=credentials["SecretKey"],
    aws_session_token=credentials["SessionToken"],
)

# IAM FGAC policy ensures only the user's own items are accessible
item = dynamo.get_item(
    TableName="GameScores",
    Key={
        "UserId":    {"S": current_user_id},
        "GameTitle": {"S": "SpaceInvaders"},
    },
)["Item"]
```

## 5. Switching Policy Types

To change the FGAC policy type without recreating the table:

```hcl
# terraform/terraform.tfvars
access_policy_type = "read_only"  # horizontal | vertical | combined | read_only
```

```bash
terraform apply
```

Only the IAM policy is updated — the DynamoDB table is unchanged.

## 6. Destroy

```bash
terraform destroy
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `AccessDeniedException: User is not authorized to perform dynamodb:PutItem` | Policy type is `read_only` or `vertical` | Use `horizontal` or `combined` |
| `ValidationException: The provided key element does not match the schema` | Wrong hash/range key types | Ensure `UserId` is String, `GameTitle` is String |
| `ExpiredTokenException` | STS temp credentials expired | Re-authenticate with Cognito to get fresh credentials |
