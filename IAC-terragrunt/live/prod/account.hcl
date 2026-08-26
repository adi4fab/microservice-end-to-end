locals {
  account_name = "prod"
  account_id   = "946299734469"

  # Temporary: the account-baseline deploy role does not exist yet
  # (chicken-and-egg). Swap to a dedicated role once the baseline is applied.
  iam_role = "arn:aws:iam::946299734469:role/OrganizationAccountAccessRole"
}
