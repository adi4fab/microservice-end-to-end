# Module defaults for DynamoDB tables

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//dynamodb?ref=v1.0.0"
}

inputs = {
  # Billing mode
  billing_mode = "PAY_PER_REQUEST" # or "PROVISIONED"

  # Encryption
  server_side_encryption_enabled = true

  # Point-in-time recovery
  point_in_time_recovery_enabled = true

  # DynamoDB Streams
  stream_enabled   = false
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    ManagedBy = "Terragrunt"
  }
}
