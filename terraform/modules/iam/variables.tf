variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "table_arn" {
  description = "ARN of the DynamoDB table to grant access to"
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID used in the trust policy"
  type        = string
  default     = ""
}

variable "allowed_identity_providers" {
  description = "List of federated identity providers"
  type        = list(string)
  default     = ["cognito-identity.amazonaws.com"]
}

variable "access_policy_type" {
  description = "Type of fine-grained access policy: horizontal, vertical, combined, read_only"
  type        = string
  default     = "combined"
}
