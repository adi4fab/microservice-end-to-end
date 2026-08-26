locals {
  account_name = "mgmt"
  account_id   = "339712844367"

  # mgmt applies with a human + MFA only. No role assumption, by design.
  iam_role = null
}
