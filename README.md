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

Control how many units run concurrently (`TG_PARALLELISM`; old name was
`TERRAGRUNT_PARALLELISM`):

```console
export TG_PARALLELISM=10
```

> First apply note: with `TF_PLUGIN_CACHE_DIR` set, the very first parallel run
> can race while populating the provider cache ("Required plugins are not
> installed"). Warm it once with `TG_PARALLELISM=1`, then bump back to 10 — or
> just re-run.

## Terragrunt Commands

Terragrunt 0.78+ renamed `run-all` to `run --all`. Dependencies are applied in
order automatically (e.g. kms before s3) — no mock outputs needed.

```console
terragrunt run --all plan
terragrunt run --all apply
terragrunt run --all destroy

# scope to one account/region/unit with --working-dir, e.g.
AWS_PROFILE=dev terragrunt run --all apply --working-dir live/dev/us-west-1
```

## State backend bootstrap

Terragrunt 0.78+ no longer auto-creates the state bucket — bootstrap it once per
account (idempotent). Uses `use_lockfile = true`, so S3 only, no DynamoDB.

```console
AWS_PROFILE=dev  terragrunt backend bootstrap --all --working-dir IAC-terragrunt/live/dev
AWS_PROFILE=prod terragrunt backend bootstrap --all --working-dir IAC-terragrunt/live/prod
```

## Local Kubernetes (kind on Docker Desktop)

Local multi-node cluster for running the microservices end-to-end. Requires
Docker Desktop running (its built-in Kubernetes can stay OFF — kind provides
the cluster).

### Install

```console
brew install --cask docker-desktop
brew install kind
```

### Cluster topology

Defined in [`kind-config.yaml`](kind-config.yaml): 1 control-plane + 2 workers.
The Kubernetes node names (shown by `kubectl get nodes`) are set via
`nodeRegistration.name` in the config:

| Kubernetes node name | Role | Docker container (kind-managed) |
| --- | --- | --- |
| `microsvc-control-plane` | control-plane (master) | `microsvc-control-plane` |
| `microsvc-worker-1` | worker | `microsvc-worker` |
| `microsvc-worker-2` | worker | `microsvc-worker2` |

### Commands

```console
# create the 3-node cluster (context: kind-microsvc)
kind create cluster --config kind-config.yaml

# verify
kubectl get nodes -o wide
kubectl config current-context        # -> kind-microsvc

# list / switch clusters
kind get clusters
kubectl config use-context kind-microsvc

# tear down
kind delete cluster --name microsvc
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
