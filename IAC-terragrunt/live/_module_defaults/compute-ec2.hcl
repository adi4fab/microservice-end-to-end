# Module defaults for EC2 instances

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//ec2?ref=v1.0.0"
}

inputs = {
  instance_type = "t3.micro"

  # Monitoring
  monitoring = true

  # Storage
  root_block_device = {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    ManagedBy = "Terragrunt"
  }
}
