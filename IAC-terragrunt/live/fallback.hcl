# Default values for find_in_parent_folders(<file>, "fallback.hcl").
#
# WHY THIS EXISTS
# root.hcl is included by every unit, and it calls find_in_parent_folders().
# With one argument that function is a HARD ERROR when the file is missing —
# which kills repo-wide commands (run --all from the root, CI linting, tooling)
# and, during bootstrap, any account folder whose account.hcl is not filled in
# yet. The second argument makes it return these values instead of aborting.
#
# WHY THE VALUES LOOK LIKE THIS
# A real unit never uses them. If one ever does, something is wrong — so the
# value must SAY what is wrong. AWS will reject every one of these, and the
# error text names the missing file instead of being an opaque "invalid region".
#
# TRADE-OFF, STATED PLAINLY
# This turns a clear Terragrunt "file not found" into a later AWS-layer failure.
# Gruntwork's own reference repo does NOT do this and accepts the crash.
# Loud sentinels are what make the trade survivable.
locals {
  account_name = "MISSING-account.hcl-IN-PARENT-TREE"
  account_id   = "MISSING-account.hcl-IN-PARENT-TREE"
  aws_region   = "MISSING-region.hcl-IN-PARENT-TREE"
  region_short = "MISSING-region.hcl-IN-PARENT-TREE"
  iam_role     = null
}
