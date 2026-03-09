# Game Scores Example — Combined Fine-Grained Access Control

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "game_scores_fgac" {
  source = "../../terraform"

  aws_region               = "us-east-1"
  project_name             = "game-app"
  environment              = "dev"
  table_name               = "GameScores"
  billing_mode             = "PAY_PER_REQUEST"
  enable_point_in_time_recovery = true
  enable_ttl               = false

  # Replace with your Cognito Identity Pool ID
  cognito_identity_pool_id = "us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Options: horizontal | vertical | combined | read_only
  access_policy_type       = "combined"
}

output "table_name" {
  value = module.game_scores_fgac.dynamodb_table_name
}

output "iam_role_arn" {
  value = module.game_scores_fgac.iam_role_arn
}
