locals {
  account_name = "dev"
  account_id   = "311212293512"

  # Temporary: the account-baseline deploy role does not exist yet
  # (chicken-and-egg). Swap to a dedicated role once the baseline is applied.
  iam_role = "arn:aws:iam::311212293512:role/OrganizationAccountAccessRole"
}
