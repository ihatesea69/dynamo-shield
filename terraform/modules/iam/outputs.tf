output "role_arn" {
  description = "ARN of the IAM role for fine-grained DynamoDB access"
  value       = aws_iam_role.dynamodb_fgac.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.dynamodb_fgac.name
}

output "policy_arn" {
  description = "ARN of the fine-grained access IAM policy"
  value       = aws_iam_policy.dynamodb_fgac.arn
}

output "policy_name" {
  description = "Name of the fine-grained access IAM policy"
  value       = aws_iam_policy.dynamodb_fgac.name
}
