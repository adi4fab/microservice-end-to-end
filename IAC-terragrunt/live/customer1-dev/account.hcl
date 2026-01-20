locals {
  account_name = "customer1-dev"
  customer     = "customer1"
  environment  = "dev"

  route53_zone_name_public = "thekiseki.com"
  route53_zone_id_public = "Z03747862XQWQUCB7WB6M"
  aws_account_id = "339712844367"


  common_tags = {
    Customer    = "customer1"
    Environment = "dev"
    ManagedBy   = "Terragrunt"
  }
}