# THE root config. There is exactly one of these in the repo.
# Every unit reaches it via find_in_parent_folders("root.hcl").

locals {
  # fallback.hcl supplies loud sentinel values so this file parses from anywhere,
  # including the repo root where no account/region context exists.
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "fallback.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl", "fallback.hcl"))
  common_vars  = read_terragrunt_config("${get_repo_root()}/IAC-terragrunt/live/common.hcl")

  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.account_id
  aws_region   = local.region_vars.locals.aws_region
  region_short = local.region_vars.locals.region_short

  # null  -> no role assumption (mgmt: human with MFA only)
  # arn   -> assume this role (member accounts)
  iam_role = lookup(local.account_vars.locals, "iam_role", null)

  # Tag keys are namespaced. EKS, Karpenter and the ALB controller all write
  # bare Name/Environment tags — a prefix means a tag query returns OUR intent.
  tag_ns = local.common_vars.locals.name_prefix

  default_region  = local.common_vars.locals.default_region
  name_prefix     = local.common_vars.locals.name_prefix
  service_catalog = local.common_vars.locals.service_catalog

  # The unit's own path in this repo. Tagged onto every resource so you can
  # jump from a console resource straight to the code that made it.
  iac_directory = path_relative_to_include()
}

# OpenTofu, not Terraform.
terraform_binary = "tofu"

# ---------------------------------------------------------------------------
# provider.tf
# ---------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-PROVIDER
    provider "aws" {
      region = "${local.aws_region}"

      # A unit in the wrong folder fails here instead of deploying to the wrong account.
      allowed_account_ids = ["${local.account_id}"]
    %{~if local.iam_role != null}

      assume_role {
        role_arn = "${local.iam_role}"
      }
    %{~endif}

      # Defaults are merged LAST on purpose: merge() gives right-hand precedence,
      # so a unit CANNOT clobber a mandatory tag. Convention becomes structure.
      default_tags {
        tags = merge(var.additional_resource_tags, {
          "${local.tag_ns}:managed-by"           = "terragrunt"
          "${local.tag_ns}:iac-directory"        = "${local.iac_directory}"
          "${local.tag_ns}:service-registry-key" = var.service_registry_key
        })
      }
    }

    # Ownership key, validated against service_catalog.json.
    # NO DEFAULT, deliberately — a forgotten key must fail at plan, not tag
    # everything "untagged" and apply clean.
    variable "service_registry_key" {
      type        = string
      description = "Owning service. Must exist in service_catalog.json."

      validation {
        condition     = contains(${jsonencode(local.service_catalog)}, var.service_registry_key)
        error_message = "service_registry_key must be one of: ${join(", ", local.service_catalog)}"
      }
    }

    # Extra tags a unit may add. Cannot override the mandatory three above.
    variable "additional_resource_tags" {
      type        = map(string)
      description = "Unit-specific tags, merged UNDER the mandatory defaults."
      default     = {}
    }
  PROVIDER
}

# ---------------------------------------------------------------------------
# provider_version_override.tf
# ---------------------------------------------------------------------------
# A generated override BEATS module-declared constraints, so this is a real
# ceiling rather than a suggestion. Floor+ceiling, never an exact pin — an
# exact pin blocks every module that needs a newer major and gets deleted.
generate "provider_version" {
  path      = "provider_version_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-PROVIDERVERSION
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = ">= 5.0, < 7.0"
        }
      }
    }
  PROVIDERVERSION
}

# ---------------------------------------------------------------------------
# terraform.tf
# ---------------------------------------------------------------------------
# NOT versions.tf — most public modules ship their own versions.tf and
# terragrunt refuses to overwrite a file it did not generate.
generate "versions" {
  path      = "terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-VERSIONS
    terraform {
      required_version = ">= 1.6.0, < 2.0.0"
    }
  VERSIONS
}

# ---------------------------------------------------------------------------
# backend
# ---------------------------------------------------------------------------
# One bucket per account, always in default_region even for other-region units.
# Terragrunt creates the bucket on first use.
# The backend does NOT inherit the provider's assume_role — it authenticates
# separately. Without this, state operations run against whatever credentials
# are ambient, which is almost never the target account.
remote_state {
  backend = "s3"
  config = merge(
    {
      bucket       = "${local.name_prefix}-${local.account_name}-tf-state"
      key          = "${path_relative_to_include()}/terraform.tfstate"
      region       = local.default_region
      encrypt      = true
      use_lockfile = true
    },
    local.iam_role == null ? {} : {
      assume_role = {
        role_arn = local.iam_role
      }
    }
  )
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
