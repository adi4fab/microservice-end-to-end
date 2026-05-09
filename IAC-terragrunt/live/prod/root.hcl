locals {
  vars        = yamldecode(file(find_in_parent_folders("account_common_vars.yaml")))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<PROVIDER
provider "aws" {
  region              = "${local.aws_region}"
  allowed_account_ids = ["${local.vars.aws_account_id}"]

  default_tags {
    tags = ${jsonencode(local.vars.tags)}
  }
}
PROVIDER
}

remote_state {
  backend = "s3"
  config = {
    encrypt                   = true
    bucket                    = "${local.vars.account_name}-${local.vars.primary_short}-s3-tf-state"
    key                       = "${path_relative_to_include()}/terraform.tfstate"
    region                    = local.aws_region
    use_lockfile              = true
    accesslogging_bucket_name = "${local.vars.account_name}-${local.vars.primary_short}-s3-tf-state-logs"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
