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
