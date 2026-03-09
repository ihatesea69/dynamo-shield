variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Provisioned read capacity units"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Provisioned write capacity units"
  type        = number
  default     = 5
}

variable "enable_point_in_time_recovery" {
  description = "Enable PITR"
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Enable TTL"
  type        = bool
  default     = false
}

variable "ttl_attribute" {
  description = "TTL attribute name"
  type        = string
  default     = "ExpiresAt"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}
