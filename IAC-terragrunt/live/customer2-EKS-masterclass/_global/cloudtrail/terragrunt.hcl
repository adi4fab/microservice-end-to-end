include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//cloudtrail?ref=v1.0.0"
}

inputs = {
  # Add your CloudTrail-specific inputs here
}
