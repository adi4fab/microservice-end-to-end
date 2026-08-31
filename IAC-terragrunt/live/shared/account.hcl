locals {
  account_name = "shared"
  account_id   = "388040682347"

  # Temporary: the account-baseline deploy role does not exist yet
  # (chicken-and-egg). Swap to a dedicated role once the baseline is applied.
  iam_role = "arn:aws:iam::388040682347:role/OrganizationAccountAccessRole"
}
