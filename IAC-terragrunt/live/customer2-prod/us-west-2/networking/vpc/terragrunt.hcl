# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for VPC
include "module_defaults" {
  path   = "${get_repo_root()}/_module_defaults/networking-vpc.hcl"
  expose = true
}

# Override defaults for this specific environment
inputs = {
  # Example: Override VPC CIDR for this environment
  # vpc_cidr = "10.1.0.0/16"

  # Example: Override AZs for this region
  # azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
