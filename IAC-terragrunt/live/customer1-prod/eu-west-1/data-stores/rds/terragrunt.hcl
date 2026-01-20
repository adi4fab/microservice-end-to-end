# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Include module defaults for RDS PostgreSQL
include "module_defaults" {
  path = "${get_repo_root()}/_module_defaults/data-stores-rds-postgres.hcl"
  expose = true
}

inputs = {
  # Example: Override for production
  # instance_class = "db.r6g.xlarge"
  # multi_az = true
  # allocated_storage = 100
}
