# Terragrunt setup

## Install

OSX:

```console
brew install terragrunt
```

## Cache management

To optmize the cache management, export the variables:

```
vi .zshrc
export TG_DOWNLOAD_DIR="$HOME/.terragrunt-cache"
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p ~/.terragrunt-cache
mkdir -p ~/.terraform.d/plugin-cache
source ~/.zshrc
```

## Parallelism

To limit the parallelism export:

```console
export TERRAGRUNT_PARALLELISM=4
```

## Commands

```console
terragrunt run-all plan
terragrunt run-all apply
terragrunt run-all destroy
```

## Install
****

- Install pre-commit

```jsx
brew install pre-commit
pre-commit --version
```

- Create the file `.pre-commit-config.yaml` at root of the repo

```jsx
repos:
  # -----------------------------
  # Basic repo hygiene
  # -----------------------------
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-merge-conflict
      - id: end-of-file-fixer
      - id: trailing-whitespace
      - id: check-yaml

  # -----------------------------
  # Terraform
  # -----------------------------
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.96.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate

  # -----------------------------
  # Terragrunt
  # -----------------------------
  - repo: local
    hooks:
      - id: terragrunt_fmt
        name: terragrunt hcl fmt
        entry: terragrunt hcl fmt
        language: system
        files: \.hcl$
      - id: terragrunt_validate
        name: terragrunt validate
        entry: terragrunt validate
        language: system
        files: terragrunt\.hcl$
        pass_filenames: false

```

- `pre-commit install` run this command at the root of the repo.
- run for specific folder

```jsx
pre-commit run --files $(git ls-files customer1-dev)
```
