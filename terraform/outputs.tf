output "dynamodb_table_name" {
  description = "Name of the created DynamoDB table"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the created DynamoDB table"
  value       = module.dynamodb.table_arn
}

output "dynamodb_table_id" {
  description = "ID of the created DynamoDB table"
  value       = module.dynamodb.table_id
}

output "iam_role_arn" {
  description = "ARN of the IAM role for fine-grained DynamoDB access"
  value       = module.iam.role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role for fine-grained DynamoDB access"
  value       = module.iam.role_name
}

output "iam_policy_arn" {
  description = "ARN of the IAM policy attached to the role"
  value       = module.iam.policy_arn
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}
