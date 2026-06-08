# CLAUDE.md

Project context for Claude Code. Auto-loaded each session.

## Repository layout

- `IAC-terraform/` — Terraform infrastructure-as-code
- `IAC-terragrunt/` — Terragrunt configuration (wraps Terraform)
- `kind-config.yaml` — local Kubernetes cluster definition (kind)
- `README.md` — Terragrunt + local Kubernetes setup docs
- `.pre-commit-config.yaml` — pre-commit hooks (terraform fmt, terragrunt hcl fmt, yaml/whitespace/EOF checks)

## Local Kubernetes environment

The microservices stack runs locally on a **kind** cluster backed by **Docker Desktop**.

- **Container engine:** Docker Desktop (macOS). Its built-in Kubernetes is left **OFF** — kind provides the cluster.
- **Cluster tool:** kind (Kubernetes IN Docker). Each "node" is a Docker container.
- **kubectl context:** `kind-microsvc`
- **Topology:** 1 control-plane + 2 workers (defined in `kind-config.yaml`)

| Kubernetes node name | Role | kind-managed Docker container |
| --- | --- | --- |
| `microsvc-control-plane` | control-plane (master) | `microsvc-control-plane` |
| `microsvc-worker-1` | worker | `microsvc-worker` |
| `microsvc-worker-2` | worker | `microsvc-worker2` |

> Worker k8s node names are overridden via `nodeRegistration.name` in `kind-config.yaml`. The underlying Docker container names (`microsvc-worker`, `microsvc-worker2`) are fixed by kind and only appear in `docker ps`.

### Cluster commands

```console
kind create cluster --config kind-config.yaml   # create (context: kind-microsvc)
kubectl get nodes -o wide                        # verify
kind get clusters                                # list
kind delete cluster --name microsvc              # tear down
```

### Why kind (not Docker Desktop / Rancher built-in k8s)

The user wants **multi-node** for testing real pod scheduling. No desktop tool's
built-in Kubernetes (Docker Desktop or Rancher Desktop) does true multi-node —
those are always single-node. Multi-node locally = nodes-as-containers (kind/k3d)
or nodes-as-VMs (minikube). kind on Docker Desktop is the chosen setup. Do not
suggest Rancher Desktop (it was tried and reverted).

## Git workflow

- Default branch: `main`. The user merges via **pull requests**, not direct commits to main.
- `gh` CLI is installed and authenticated (account `adi4fab`, SSH, `repo` scope) —
  open PRs directly with `gh pr create` and hand over the live link.
- Standard flow: branch → commit → push → `gh pr create` → user merges → sync main + prune branch.
- `.claude/worktrees/` and `.claude/settings.local.json` are gitignored.

## Tooling

- **Terragrunt:** `terragrunt run-all plan|apply|destroy` (see README for cache/parallelism env vars).
- **Pre-commit:** runs on commit; `pre-commit run --files $(git ls-files <folder>)` for a specific folder.
