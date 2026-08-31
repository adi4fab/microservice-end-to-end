locals {
  account_name = "security"
  account_id   = "725166342008"

  # Temporary: the account-baseline deploy role does not exist yet
  # (chicken-and-egg). Swap to a dedicated role once the baseline is applied.
  iam_role = "arn:aws:iam::725166342008:role/OrganizationAccountAccessRole"
}
