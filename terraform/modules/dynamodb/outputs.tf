output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.game_scores.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.game_scores.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.game_scores.id
}

output "table_stream_arn" {
  description = "Stream ARN of the DynamoDB table (empty if streams disabled)"
  value       = aws_dynamodb_table.game_scores.stream_arn
}

output "gsi_name" {
  description = "Name of the GameTitleIndex GSI"
  value       = "GameTitleIndex"
}
