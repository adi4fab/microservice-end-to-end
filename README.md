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
