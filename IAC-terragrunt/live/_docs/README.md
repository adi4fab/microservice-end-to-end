# IAC-terragrunt

Multi-account AWS infra. **OpenTofu** + **Terragrunt**.

## Accounts

| Account | Role | `iam_role` |
|---|---|---|
| `mgmt` | Org, billing, Identity Center instance | `null` — human + MFA only |
| `security` | Delegated admin — permission sets, assignments | assumes a role |
| `shared` | CI/CD — runners, Atlantis, ECR | assumes a role |
| `dev` · `prod` | Workloads | assumes a role |

CI lives in `shared`, identity lives in `security` — **different accounts**, so a bot
can't grant itself admin.

## Layout

```
<account>/_global/<category>/<resource>/     IAM, Organizations, Identity Center
<account>/<region>/<category>/<resource>/    VPC, EKS, S3, RDS
```

```
mgmt/_global/organization/service-control-policies/
security/_global/identity/identity-center/
dev/us-east-1/networking/vpc/
```

- **No environment level** — 1 account = 1 env
- `_global` and `<region>` are sibling branches, so a unit finds exactly one `region.hcl`
- `<category>` comes from `service_catalog.json`

## Config files

| File | Scope | Holds |
|---|---|---|
| `live/common.hcl` | all accounts | `default_region`, `name_prefix`, `internal_dns_domain` |
| `live/<account>/account.hcl` | one account | `account_name`, `account_id`, `iam_role` |
| `live/<account>/<region>/region.hcl` | one region | `aws_region`, `region_short` |

> **A human chose it → `common.hcl`.**
> **An `apply` produced it → `dependency` / `data` source.**

No org id, bucket names or ARNs in `common.hcl` — they go stale silently. Read live:

```hcl
data "aws_organizations_organization" "this" {}
```

## root.hcl

One file at `live/`. Every unit includes it. Generates:

| File | Carries |
|---|---|
| `provider.tf` | region · `allowed_account_ids` · `assume_role` · tags |
| `provider_version_override.tf` | AWS provider `>= 5.0, < 7.0` |
| `terraform.tf` | `required_version` (**not** `versions.tf` — modules ship their own) |
| `backend.tf` | S3, one bucket per account, `use_lockfile` |

## Naming and tags

```
onlythetop-dev-tf-state          names
onlythetop:managed-by            tag keys
onlythetop:iac-directory
onlythetop:service-registry-key
```

- Tag keys are namespaced — EKS, Karpenter and the ALB controller all write bare tags
- Defaults merged **last**, so a unit can't clobber them
- `service_registry_key` required, no default — a forgotten key fails at plan
- **Never** add `Name` to `default_tags` → perpetual diffs

## Guardrails

1. `allowed_account_ids` — wrong folder fails instead of deploying wrong
2. `iac-directory` tag — console resource → its code
3. Merge order — mandatory tags un-overridable
4. Provider ceiling — no silent major bump

## Divergences from Gruntwork

| Theirs | Ours | Why |
|---|---|---|
| State bucket per account **and** region | One per account | Single-region for now |
| Terragrunt Stacks | Plain units | Stacks has no `dependency` support; breaks Atlantis |

## The four repos

| Repo | Holds |
|---|---|
| **`infra-live`** | This repo — the Terragrunt tree, what exists in AWS |
| [`infra-modules`](https://github.com/adi4fab/infra-modules) | Reusable OpenTofu modules. Blueprints only |
| [`k8s`](https://github.com/adi4fab/k8s) | Kubernetes manifests, local cluster config |
| [`microservices`](https://github.com/adi4fab/microservices) | Application code |

Modules live in their **own repo**, sourced with `git::` + a pinned `?ref=`, as
Gruntwork recommends.

- **Why:** independent versioning — run `v1.2.0` in prod while testing `v1.3.0` in dev
- A local `modules/` folder cannot do that: change it and every unit gets it on the
  next apply
- ⚠️ **A module change is not live until this repo bumps its `?ref=`**

## Module sources

Always `git::`, always pinned:

```hcl
source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc?ref=v5.8.1"
```

**Never** `tfr:///…` — three slashes resolves to **registry.terraform.io**, even when
the engine is OpenTofu. The registry is only an index over GitHub; go straight to the
repo and pin the tag.

`service_catalog.json` does double duty — category folder **and** ownership tag.
Fine while there's one owner. Split when there's more than one.

## Gotchas

- **zsh eats `:r`** — `$id:role/` becomes `${id:r}` + `ole/`. Always brace `${id}:role/`
- **`--backend-bootstrap` ignores the backend's `assume_role`** — creates the bucket in the wrong account
- **The backend authenticates separately from the provider** — it needs its own `assume_role`
