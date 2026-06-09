include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  vars         = yamldecode(file(find_in_parent_folders("account_common_vars.yaml")))
  region_short = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region_short
}

terraform {
  source = "tfr:///terraform-aws-modules/secrets-manager/aws?version=2.1.0"
}

inputs = {
  name        = "${local.vars.env.dev}-${local.region_short}-csv-processor"
  description = "Runtime config for the csv-processor app. Real values are set in the AWS console."

  ignore_secret_changes = true
  secret_string = jsonencode({
    S3_BUCKET  = "REPLACE_VIA_AWS_CONSOLE"
    AWS_REGION = "REPLACE_VIA_AWS_CONSOLE"
  })

  recovery_window_in_days = 7

  tags = merge(local.vars.tags, { Environment = local.vars.env.dev })
}
