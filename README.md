# microservice-end-to-end

## INFRASTRUCTURE ##

# Terragrunt setup

## Install

OSX:

```console
brew install terragrunt
```

## Cache management

To optmize the cache management, export the variables:

```
export TERRAGRUNT_DOWNLOAD="~/.terragrunt-cache"
export TF_PLUGIN_CACHE_DIR="~/.terraform.d/plugin-cache"
```

## Parallelism

To limit the parallelism export:

```console
export TERRAGRUNT_PARALLELISM=4
```
