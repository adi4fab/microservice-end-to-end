# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for ECR
include "module_defaults" {
  path   = "${get_repo_root()}/_module_defaults/global-ecr.hcl"
  expose = true
}

inputs = {
  # Add ECR-specific configurations here
}
