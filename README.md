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

## Terragrunt Commands

```console
terragrunt run-all plan
terragrunt run-all apply
terragrunt run-all destroy
```

## Install pre-commit

```console
brew install pre-commit
pre-commit --version
```

- Create the file `.pre-commit-config.yaml` at root of the repo, contents can see in the file.
- `pre-commit install` run this command at the root of the repo.
- To run for specific folder use below command
```console
pre-commit run --files $(git ls-files customer1-dev)
```
