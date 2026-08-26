# Org-wide constants. Read by root.hcl, available to every unit.
locals {
  live_dir = "${get_repo_root()}/IAC-terragrunt/live"

  # Every backend bucket lives here, regardless of the unit's own region.
  default_region = "us-east-1"

  # Org prefix. Used for BOTH jobs, exactly as Charizard does it:
  #   - tag key namespace     -> onlythetop:managed-by
  #   - globally-unique names -> onlythetop-dev-tf-state
  # Splitting into two values only pays off when a name hits a length cap
  # (RDS 63 / ElastiCache 40). Longest name today is ~23 chars.
  name_prefix = "onlythetop"

  # Real registered domain. Used for Route53 zones, ACM certs, internal records.
  # Never put an aspirational domain here — DNS config against a domain you do
  # not own fails silently and late.
  internal_dns_domain = "onlythetop.in"

  # NOTHING PRODUCED BY AN APPLY BELONGS IN THIS FILE.
  #
  # The rule: a human chose it -> constant, lives here.
  #           an apply produced it -> dependency or data source, NOT here.
  #
  # So no org_id, no account list, no bucket names, no KMS ARNs. Read those live:
  #   data "aws_organizations_organization" "this" {}
  #     .id             -> the org id
  #     .accounts[*].id -> every account id
  #
  # Cached apply outputs are the exact smell on Charizard's tech-debt list:
  # they go stale silently when the producing unit is recreated, with no drift
  # detection. A live lookup cannot drift.

  # Valid ownership keys. Enforced by a validation block in the generated provider,
  # so a typo fails at PLAN time rather than in review.
  service_catalog = jsondecode(file("${local.live_dir}/service_catalog.json")).services

  # Accounts that SSO permission sets are never assigned into.
  # mgmt is excluded on purpose: a delegated admin cannot manage assignments
  # into the management account, and you should never SSO into org-admin.
  sso_excluded_accounts = ["mgmt"]
}
