include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  vars         = yamldecode(file(find_in_parent_folders("account_common_vars.yaml")))
  region_short = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region_short
}

terraform {
  source = "tfr:///terraform-aws-modules/kms/aws?version=4.2.0"
}

inputs = {
  description             = "CMK for csv-processor S3 bucket (${local.vars.env.dev}-${local.region_short})"
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  aliases = ["${local.vars.env.dev}-${local.region_short}-csv-processor"]

  tags = merge(local.vars.tags, { Environment = local.vars.env.dev })
}
