variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "dynamodb-fgac"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "table_name" {
  description = "Name of the DynamoDB GameScores table"
  type        = string
  default     = "GameScores"
}

variable "billing_mode" {
  description = "DynamoDB billing mode: PAY_PER_REQUEST or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "Billing mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "read_capacity" {
  description = "Read capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "enable_point_in_time_recovery" {
  description = "Enable Point-in-Time Recovery for the DynamoDB table"
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Enable TTL on the DynamoDB table"
  type        = bool
  default     = false
}

variable "ttl_attribute" {
  description = "Attribute name for TTL (required if enable_ttl is true)"
  type        = string
  default     = "ExpiresAt"
}

variable "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID for Web Identity federation"
  type        = string
  default     = ""
}

variable "allowed_identity_providers" {
  description = "List of identity providers allowed to assume the IAM role (e.g. cognito-identity.amazonaws.com)"
  type        = list(string)
  default     = ["cognito-identity.amazonaws.com"]
}

variable "access_policy_type" {
  description = "Fine-grained access policy type: horizontal, vertical, combined, or read_only"
  type        = string
  default     = "combined"

  validation {
    condition     = contains(["horizontal", "vertical", "combined", "read_only"], var.access_policy_type)
    error_message = "access_policy_type must be one of: horizontal, vertical, combined, read_only."
  }
}
