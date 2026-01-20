# Module defaults for RDS MySQL instances

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//rds-mysql?ref=v1.0.0"
}

inputs = {
  engine         = "mysql"
  engine_version = "8.0.35"

  # Instance configuration
  instance_class    = "db.t3.medium"
  allocated_storage = 50
  storage_type      = "gp3"
  storage_encrypted = true

  # Backup configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # High availability
  multi_az = false # Override to true in prod

  # Performance Insights
  performance_insights_enabled = true

  # Deletion protection
  deletion_protection = true
  skip_final_snapshot = false

  tags = {
    ManagedBy = "Terragrunt"
  }
}
