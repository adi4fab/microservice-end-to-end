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
    bucket                    = "${get_env("TG_BUCKET_PREFIX", "")}tf-state-${local.vars.account_name}-${local.aws_region}"
    key                       = "${path_relative_to_include()}/terraform.tfstate"
    region                    = local.aws_region
    use_lockfile              = true
    accesslogging_bucket_name = "${get_env("TG_BUCKET_PREFIX", "")}tf-state-logs-${local.vars.account_name}-${local.aws_region}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
