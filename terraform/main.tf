data "aws_caller_identity" "current" {}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name                    = var.table_name
  billing_mode                  = var.billing_mode
  read_capacity                 = var.read_capacity
  write_capacity                = var.write_capacity
  enable_point_in_time_recovery = var.enable_point_in_time_recovery
  enable_ttl                    = var.enable_ttl
  ttl_attribute                 = var.ttl_attribute
  environment                   = var.environment
  project_name                  = var.project_name
}

module "iam" {
  source = "./modules/iam"

  project_name               = var.project_name
  environment                = var.environment
  table_arn                  = module.dynamodb.table_arn
  table_name                 = module.dynamodb.table_name
  account_id                 = data.aws_caller_identity.current.account_id
  aws_region                 = var.aws_region
  cognito_identity_pool_id   = var.cognito_identity_pool_id
  allowed_identity_providers = var.allowed_identity_providers
  access_policy_type         = var.access_policy_type
}
