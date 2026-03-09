resource "aws_dynamodb_table" "game_scores" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = "UserId"
  range_key    = "GameTitle"

  # Capacity — only relevant when billing_mode = PROVISIONED
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  # Global Secondary Index: query by game title to produce leaderboards
  global_secondary_index {
    name            = "GameTitleIndex"
    hash_key        = "GameTitle"
    range_key       = "Score"
    projection_type = "ALL"

    read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
    write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  }

  attribute {
    name = "Score"
    type = "N"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  dynamic "ttl" {
    for_each = var.enable_ttl ? [1] : []
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = var.table_name
    Environment = var.environment
    Project     = var.project_name
  }
}
