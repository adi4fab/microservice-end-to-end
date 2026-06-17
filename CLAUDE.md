# CLAUDE.md

Project context for Claude Code. Auto-loaded each session.

## What this repo is for (learning context)

This is the user's hands-on learning environment. They are learning, and will
build out: **CKA, EKS, Helm, Argo CD, service mesh, monitoring & logging, tool
integrations, IdP/SSO**, and more over time. Treat new tools/integrations as
expected, not scope creep.

## How to work with the user (read before every change)

Whenever you make a code change, a plan, an execution, or any decision —
**explain it first, in simple terms**:

- Use **short bullet points**, plain language. Do **not** overload with detail.
- Cover the **what** and the **why** — what we're doing and why we're doing it.
- Give a **real-world scenario** so the concept lands (not just abstract steps).
- Call out **caveats / gotchas** explicitly.
- Goal is understanding the **concept**, not just running commands.

## Always build prod-grade, never dev/learning shortcuts

Even though this is a learning environment, **set everything up the way it would
be in production** — and explain how/why prod differs.

- Default to **private, not public** (e.g. private subnets/endpoints, no public
  exposure unless explicitly required). Real systems are private by default.
- No "just for demo" shortcuts (no hardcoded secrets, no `:latest`, no skipping
  RBAC/network policy/TLS). If a shortcut is taken for local reasons, **say so**
  and note what the prod equivalent would be.
- The local kind setup is only a stand-in to *demonstrate* the prod pattern.

## Company EKS setup (to replicate later)

The user's company uses specific setups for EKS etc. They will **paste that code
later** to replicate the patterns in this learning environment. Expect it, and
align the learning setup to those real-world patterns when provided.

## Repository layout

- `IAC-terraform/` — Terraform infrastructure-as-code
- `IAC-terragrunt/` — Terragrunt configuration (wraps Terraform)
- `kind-config.yaml` — local Kubernetes cluster definition (kind)
- `README.md` — Terragrunt + pre-commit setup docs
- `.pre-commit-config.yaml` — pre-commit hooks (terraform fmt, terragrunt hcl fmt, yaml/whitespace/EOF checks)

## Git workflow

- Default branch: `main`. The user merges via **pull requests**, not direct commits to main.
- `gh` CLI is installed and authenticated (account `adi4fab`, SSH, `repo` scope) —
  open PRs directly with `gh pr create` and hand over the live link.
- Standard flow: branch → commit → push → `gh pr create` → user merges → sync main + prune branch.
- `.claude/worktrees/` and `.claude/settings.local.json` are gitignored.

## Tooling

- **Terragrunt:** `terragrunt run-all plan|apply|destroy` (see README for cache/parallelism env vars).
- **Pre-commit:** runs on commit; `pre-commit run --files $(git ls-files <folder>)` for a specific folder.
