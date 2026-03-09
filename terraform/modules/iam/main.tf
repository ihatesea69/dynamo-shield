locals {
  role_name = "${var.project_name}-${var.environment}-dynamodb-fgac-role"

  # Trust policy: allow Cognito Identity (web identity federation) to assume this role
  trust_policy = var.cognito_identity_pool_id != "" ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = var.cognito_identity_pool_id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  }) : jsonencode({
    # Fallback trust policy for testing — allows direct STS assumption via identity providers
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
      }
    ]
  })

  # -----------------------------------------------------------------------
  # Access policies keyed by type
  # -----------------------------------------------------------------------
  horizontal_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "HorizontalAccessOwnItems"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [var.table_arn]
        Condition = {
          "ForAllValues:StringEquals" = {
            "dynamodb:LeadingKeys" = ["$${cognito-identity.amazonaws.com:sub}"]
          }
        }
      }
    ]
  })

  vertical_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VerticalAccessAllowedAttributes"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [var.table_arn]
        Condition = {
          "ForAllValues:StringEquals" = {
            "dynamodb:Attributes" = [
              "UserId",
              "GameTitle",
              "Score",
              "Wins",
              "Losses"
            ]
          }
          StringEqualsIfExists = {
            "dynamodb:Select" = "SPECIFIC_ATTRIBUTES"
          }
        }
      }
    ]
  })

  combined_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CombinedHorizontalAndVerticalAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = [var.table_arn]
        Condition = {
          "ForAllValues:StringEquals" = {
            "dynamodb:LeadingKeys" = ["$${cognito-identity.amazonaws.com:sub}"]
            "dynamodb:Attributes" = [
              "UserId",
              "GameTitle",
              "Score",
              "Wins",
              "Losses"
            ]
          }
          StringEqualsIfExists = {
            "dynamodb:Select" = "SPECIFIC_ATTRIBUTES"
          }
        }
      }
    ]
  })

  read_only_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadOnlyOwnItems"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query"
        ]
        Resource = [var.table_arn]
        Condition = {
          "ForAllValues:StringEquals" = {
            "dynamodb:LeadingKeys" = ["$${cognito-identity.amazonaws.com:sub}"]
          }
        }
      }
    ]
  })

  access_policies = {
    horizontal = local.horizontal_policy
    vertical   = local.vertical_policy
    combined   = local.combined_policy
    read_only  = local.read_only_policy
  }

  selected_policy = local.access_policies[var.access_policy_type]
}

# IAM Role — assumed via Web Identity (Cognito)
resource "aws_iam_role" "dynamodb_fgac" {
  name               = local.role_name
  assume_role_policy = local.trust_policy
  description        = "Role for fine-grained DynamoDB access control (${var.access_policy_type})"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    PolicyType  = var.access_policy_type
  }
}

# IAM Policy for fine-grained DynamoDB access
resource "aws_iam_policy" "dynamodb_fgac" {
  name        = "${var.project_name}-${var.environment}-dynamodb-fgac-policy"
  description = "Fine-grained access control policy for DynamoDB table ${var.table_name} (${var.access_policy_type})"
  policy      = local.selected_policy

  tags = {
    Environment = var.environment
    Project     = var.project_name
    PolicyType  = var.access_policy_type
  }
}

# Attach the access policy to the role
resource "aws_iam_role_policy_attachment" "dynamodb_fgac" {
  role       = aws_iam_role.dynamodb_fgac.name
  policy_arn = aws_iam_policy.dynamodb_fgac.arn
}
