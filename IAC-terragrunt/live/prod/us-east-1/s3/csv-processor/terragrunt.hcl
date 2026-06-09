include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  vars         = yamldecode(file(find_in_parent_folders("account_common_vars.yaml")))
  region_short = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region_short
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=5.14.0"
}

dependency "kms" {
  config_path = "../../kms/csv-processor"
}

inputs = {
  bucket        = "${local.vars.env.prod}-${local.region_short}-csv-processor"
  force_destroy = false

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = dependency.kms.outputs.key_arn
      }
      bucket_key_enabled = true
    }
  }

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  lifecycle_rule = [
    {
      id      = "processed-archive"
      enabled = true
      filter = {
        prefix = "processed/"
      }
      transition = [
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
      abort_incomplete_multipart_upload_days = 7
    }
  ]

  tags = merge(local.vars.tags, { Environment = local.vars.env.prod })
}
