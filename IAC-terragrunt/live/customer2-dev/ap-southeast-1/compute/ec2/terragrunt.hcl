# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for EC2
include "module_defaults" {
  path   = "${get_repo_root()}/_module_defaults/compute-ec2.hcl"
  expose = true
}

inputs = {
  # Example: Override instance type
  # instance_type = "t3.medium"
}
