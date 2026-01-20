# Module defaults for EKS clusters

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//eks?ref=v1.0.0"
}

inputs = {
  # Cluster configuration
  cluster_version = "1.28"
  
  # Node group defaults
  node_groups = {
    default = {
      desired_size = 2
      min_size     = 1
      max_size     = 4
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
  
  # Networking
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  # Add-ons
  enable_cluster_autoscaler = true
  enable_aws_load_balancer_controller = true
  
  tags = {
    ManagedBy = "Terragrunt"
  }
}
