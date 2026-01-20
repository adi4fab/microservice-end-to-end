include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//kms?ref=v1.0.0"
}

inputs = {
  # Add your KMS-specific inputs here
}
