include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  account_vars = read_terragrunt_config(
    find_in_parent_folders("account.hcl")
  )
}

terraform {
  source = "tfr:///terraform-aws-modules/route53/aws/?version=6.4.0"
}

inputs = {
  # Hosted zone
  name    = local.account_vars.locals.route53_zone_name_public
  comment = local.account_vars.locals.route53_zone_name_public
  tags    = local.account_vars.locals.common_tags

  # DNS records
  records = {
    root_a = {
      full_name = local.account_vars.locals.route53_zone_name_public
      name      = null
      type      = "A"
      ttl       = 60
      records = [
        "13.248.243.5",
        "76.223.105.230"
      ]
    }

    www = {
      name = "www"
      type = "CNAME"
      ttl  = 60
      records = [
        local.account_vars.locals.route53_zone_name_public
      ]
    }
  }
}
