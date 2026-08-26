# Local setup

## Install tools

All versions are pinned in `mise.toml` at the repo root.

```console
brew install mise
mise install          # opentofu, terragrunt, kubectl, helm, kind, k9s, yq
```

Do **not** `brew install terragrunt` — it bypasses the pin and you drift from CI.

## Cache

```console
# ~/.zshrc
export TG_DOWNLOAD_DIR="$HOME/.terragrunt-cache"
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
```

```console
mkdir -p ~/.terragrunt-cache ~/.terraform.d/plugin-cache
```

## Parallelism

```console
export TG_PARALLELISM=10
```

⚠️ **First run only:** with `TF_PLUGIN_CACHE_DIR` set, a parallel run can race
while populating the cache (*"Required plugins are not installed"*). Warm it once
with `TG_PARALLELISM=1`, then bump back.

## State backend bootstrap

Terragrunt 0.78+ no longer auto-creates the state bucket. Bootstrap once per
account — idempotent.

```console
terragrunt backend bootstrap --all --working-dir IAC-terragrunt/live/mgmt
terragrunt backend bootstrap --all --working-dir IAC-terragrunt/live/dev
```

⚠️ **Credentials must already be for the target account.** The backend does not
inherit the provider's `assume_role`, so run it under a profile that resolves to
that account — otherwise the bucket lands in whichever account your ambient
credentials point at.

Uses `use_lockfile = true` — S3 only, no DynamoDB table.

## Commands

`run-all` was renamed to `run --all` in 0.78+.

```console
terragrunt run --all plan
terragrunt run --all apply
terragrunt run --all destroy

# scope to one account / region / unit
terragrunt run --all apply --working-dir IAC-terragrunt/live/dev/us-east-1
```

Dependencies apply in order automatically.

## Pre-commit

```console
brew install pre-commit
pre-commit install            # at the repo root
```

```console
# run against one folder
pre-commit run --files $(git ls-files IAC-terragrunt)
```
