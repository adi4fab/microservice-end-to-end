include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  account_vars = read_terragrunt_config(
    find_in_parent_folders("account.hcl")
  )
}

terraform {
  source = "tfr:///terraform-aws-modules/acm/aws/?version=6.3.0"
}

inputs = {
  domain_name = local.account_vars.locals.route53_zone_name_public
  zone_id     = local.account_vars.locals.route53_zone_id_public

  subject_alternative_names = [
    "*.${local.account_vars.locals.route53_zone_name_public}",
    "${local.account_vars.locals.route53_zone_name_public}",
  ]

  validation_method   = "DNS"
  wait_for_validation = true
  tags                = local.account_vars.locals.common_tags
}
