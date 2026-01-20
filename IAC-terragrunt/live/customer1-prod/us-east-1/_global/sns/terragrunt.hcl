# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for SNS
include "module_defaults" {
  path = "${get_repo_root()}/_module_defaults/global-sns.hcl"
  expose = true
}

inputs = {
  # Add SNS-specific configurations here
}
