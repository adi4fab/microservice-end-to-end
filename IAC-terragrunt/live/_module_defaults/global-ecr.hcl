# Module defaults for ECR repositories

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//ecr?ref=v1.0.0"
}

inputs = {
  # Image scanning
  scan_on_push = true

  # Image tag mutability
  image_tag_mutability = "MUTABLE"

  # Encryption
  encryption_type = "AES256"

  # Lifecycle policy - keep last 30 images
  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 30
      }
      action = {
        type = "expire"
      }
    }]
  })

  tags = {
    ManagedBy = "Terragrunt"
  }
}
