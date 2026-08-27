# infra-live

AWS infrastructure. **What actually exists** — OpenTofu, orchestrated by Terragrunt,
across 5 accounts.

## The four repos

| Repo | Holds |
|---|---|
| **`infra-live`** | AWS infrastructure — this repo |
| [`infra-modules`](https://github.com/adi4fab/infra-modules) | Reusable OpenTofu modules. Blueprints only, creates nothing |
| [`k8s`](https://github.com/adi4fab/k8s) | Kubernetes manifests and local cluster config |
| [`microservices`](https://github.com/adi4fab/microservices) | Application code |

⚠️ **A module change is not live until this repo bumps its `?ref=`.** Merging in
`infra-modules` publishes a version; it moves no infrastructure.

## Layout

| Path | What |
|---|---|
| `IAC-terragrunt/live/` | The Terragrunt tree — 5 AWS accounts |
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
pre-commit install
```

## Guardrails

- **`allowed_account_ids`** — a unit in the wrong folder fails instead of deploying wrong
- **`iac-directory` tag** — every resource carries the repo path that made it
- **CI** — `terragrunt hcl validate`, no unpinned `git::` sources, no `tfr://` shorthand
- **gitleaks + detect-private-key** pre-commit hooks, plus GitHub push protection
- **`main` is protected** — PR required, `checks` must pass, no force-push, no deletion
