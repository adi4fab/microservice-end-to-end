# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for Lambda
include "module_defaults" {
  path = "${get_repo_root()}/_module_defaults/services-lambda.hcl"
  expose = true
}

inputs = {
  # Example: Override runtime or memory
  # runtime = "nodejs18.x"
  # memory_size = 512
  # timeout = 60
}
