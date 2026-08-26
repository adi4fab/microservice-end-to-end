# microservice-end-to-end

Hands-on AWS platform engineering — multi-account infrastructure, EKS, and the
tooling around it. Built the way it would be run in production, not the way it is
demoed.

## Layout

| Path | What |
|---|---|
| `IAC-terragrunt/` | **Primary infra.** OpenTofu + Terragrunt, 5 AWS accounts |
| `kind-config.yaml` | Local Kubernetes cluster |
| `mise.toml` | Pinned tool versions |

## Docs

| Doc | Covers |
|---|---|
| [Architecture & conventions](IAC-terragrunt/live/_docs/README.md) | Accounts, layout, config hierarchy, naming, tagging, guardrails |
| [Local setup](IAC-terragrunt/live/_docs/setup-local.md) | Tools, cache, state bootstrap, commands |

## Quick start

```console
brew install mise
mise install
```

## Guardrails

- **`allowed_account_ids`** — a unit in the wrong folder fails instead of deploying wrong
- **`iac-directory` tag** — every resource carries the repo path that made it
- **gitleaks + detect-private-key** pre-commit hooks, plus GitHub push protection
- **`main` is protected** — PR required, no force-push, no deletion
