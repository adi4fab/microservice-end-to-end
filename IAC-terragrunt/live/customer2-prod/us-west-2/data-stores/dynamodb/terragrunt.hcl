# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for DynamoDB
include "module_defaults" {
  path = "${get_repo_root()}/_module_defaults/data-stores-dynamodb.hcl"
  expose = true
}

inputs = {
  # Example: Override billing mode
  # billing_mode = "PROVISIONED"
  # read_capacity = 5
  # write_capacity = 5
}
