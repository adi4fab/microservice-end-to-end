# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for ECS
include "module_defaults" {
  path   = "${get_repo_root()}/_module_defaults/services-ecs.hcl"
  expose = true
}

inputs = {
  # Example: Override for production workloads
  # cpu = "1024"
  # memory = "2048"
  # desired_count = 4
}
