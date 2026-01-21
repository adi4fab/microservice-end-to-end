locals {
  account_name = "customer1-dev"
  customer     = "customer1"
  environment  = "dev"

  route53_zone_name_public = "thekiseki.com"
  route53_zone_id_public   = "Z011660313K8GU3HUFZB5"
  aws_account_id           = "339712844367"


  common_tags = {
    Customer    = "customer1"
    Environment = "dev"
    ManagedBy   = "Terragrunt"
  }
}
