# Module defaults for Security Groups

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//security-groups?ref=v1.0.0"
}

inputs = {
  # Default security group rules
  # Override per environment as needed

  tags = {
    ManagedBy = "Terragrunt"
  }
}
