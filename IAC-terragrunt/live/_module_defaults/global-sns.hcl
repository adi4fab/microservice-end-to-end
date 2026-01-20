# Module defaults for SNS topics

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//sns?ref=v1.0.0"
}

inputs = {
  # Encryption
  kms_master_key_id = "alias/aws/sns"

  # Delivery policy
  delivery_policy = jsonencode({
    http = {
      defaultHealthyRetryPolicy = {
        minDelayTarget     = 20
        maxDelayTarget     = 20
        numRetries         = 3
        numMaxDelayRetries = 0
        numNoDelayRetries  = 0
        numMinDelayRetries = 0
        backoffFunction    = "linear"
      }
    }
  })

  tags = {
    ManagedBy = "Terragrunt"
  }
}
