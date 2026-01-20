# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for Security Groups
include "module_defaults" {
  path = "${get_repo_root()}/_module_defaults/networking-security-groups.hcl"
  expose = true
}

inputs = {
  # Add your security group specific configurations here
}
