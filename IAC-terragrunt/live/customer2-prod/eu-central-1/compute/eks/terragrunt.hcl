# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for EKS
include "module_defaults" {
  path = "${get_repo_root()}/_module_defaults/compute-eks.hcl"
  expose = true
}

inputs = {
  # Example: Override cluster version
  # cluster_version = "1.29"
  
  # Example: Override node group configuration for production
  # node_groups = {
  #   production = {
  #     desired_size = 3
  #     min_size     = 2
  #     max_size     = 10
  #     instance_types = ["t3.large"]
  #   }
  # }
}
