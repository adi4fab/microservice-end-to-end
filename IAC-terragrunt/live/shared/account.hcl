locals {
  account_name = "shared"

  # ⚠️ PLACEHOLDER — this account does not exist in AWS yet.
  # Deliberately invalid so allowed_account_ids rejects any real run.
  # Replace after `mgmt/_global/accounts` creates the account.
  account_id = "000000000000"

  # Temporary: the account-baseline deploy role does not exist yet
  # (chicken-and-egg). Swap to a dedicated role once the baseline is applied.
  iam_role = "arn:aws:iam::000000000000:role/OrganizationAccountAccessRole"
}
