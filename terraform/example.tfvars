aws_region               = "us-east-1"
project_name             = "dynamodb-fgac"
environment              = "dev"
table_name               = "GameScores"
billing_mode             = "PAY_PER_REQUEST"
enable_point_in_time_recovery = true
enable_ttl               = false

# Replace with your Cognito Identity Pool ID
cognito_identity_pool_id = "us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Options: horizontal | vertical | combined | read_only
access_policy_type       = "combined"
