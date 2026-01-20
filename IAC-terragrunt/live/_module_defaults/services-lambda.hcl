# Module defaults for Lambda functions

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//lambda?ref=v1.0.0"
}

inputs = {
  runtime = "python3.11"

  # Memory and timeout
  memory_size = 256
  timeout     = 30

  # Environment variables (override per function)
  environment_variables = {}

  # Logging
  log_retention_in_days = 14

  # VPC configuration (if needed)
  vpc_config_enabled = false

  # Reserved concurrent executions (if needed)
  reserved_concurrent_executions = -1

  tags = {
    ManagedBy = "Terragrunt"
  }
}
