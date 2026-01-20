# Module defaults for ECS services

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//ecs?ref=v1.0.0"
}

inputs = {
  # Launch type
  launch_type = "FARGATE"
  
  # Network mode
  network_mode = "awsvpc"
  
  # Task definition defaults
  cpu    = "256"
  memory = "512"
  
  # Service configuration
  desired_count                      = 2
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  
  # Health check grace period
  health_check_grace_period_seconds = 60
  
  # Auto-scaling
  enable_autoscaling = true
  min_capacity      = 1
  max_capacity      = 4
  
  tags = {
    ManagedBy = "Terragrunt"
  }
}
