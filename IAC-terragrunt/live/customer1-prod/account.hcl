locals {
  account_name = "aws-ssa-prod"
  customer     = "aws-ssa"
  environment  = "prod"

  route53_zone_name_public = "thekiseki.com"
  route53_zone_id_public   = "Z011660313K8GU3HUFZB5"
  aws_account_id           = "339712844367"


  common_tags = {
    Customer    = "aws-ssa"
    Environment = "prod"
    ManagedBy   = "Terragrunt"
  }
}
