# kops cluster config (dev + prod)

This folder has the Kubernetes cluster definitions for **kops** — one for dev, one for prod.

The case study doesn't need a running cluster, so these are config files only: written and validated, not actually built. I checked both with kops 1.35.1 (a schema check plus a dry run that does real AWS zone/AMI lookups) and they pass clean. Kubernetes version is 1.35.5.

## What's in each folder

Each env folder (`dev/`, `prod/`) has five files:

- `cluster.yaml` — the cluster itself: networking, security, add-ons.
- `ig-control-plane.yaml` — the control-plane node(s).
- `ig-nodes-ondemand.yaml` — on-demand worker pool.
- `ig-nodes-spot.yaml` — Spot worker pool.
- `ig-nodes-mixed.yaml` — mixed on-demand + Spot pool.

> "ig" = *instance group* = a pool of EC2 nodes that share one config.

## dev vs prod

| | dev | prod |
| --- | --- | --- |
| Region | us-west-1 | us-east-1 |
| Control plane | 1 node (cheap, not HA) | 3 nodes (HA) |
| Worker pools | smaller min/max | bigger min/max |
| State bucket | `s3://microsvc-dev-kops-state` | `s3://microsvc-prod-kops-state` |

dev uses a single control-plane to keep it cheap; prod runs 3 so etcd has a real quorum. us-west-1 only gives you 2 AZs, so dev spreads across `a` + `c`; prod uses `a` + `b` + `c`.

## What the brief asked for, and where it is

- **Multiple instance groups** → control-plane + 3 worker pools.
- **A mixed instance group** → `mixedInstancesPolicy` in `nodes-spot` and `nodes-mixed` (several instance types).
- **Spot and on-demand lifecycle** → `nodes-ondemand` (on-demand), `nodes-spot` (Spot), `nodes-mixed` (both).
- **Cluster autoscaler on every worker pool** → switched on in `cluster.yaml`, with the discovery labels on each pool so it can find and scale them.

## What's hardened, in plain terms

- **IMDSv2 forced on every node** — so a hacked pod can't trick the metadata service into handing over node credentials.
- **Nothing is public** — control plane and nodes live in private subnets; you reach the API through a bastion/VPN.
- **API + SSH locked to internal IPs** (`10.0.0.0/8`), never open to the world.
- **API audit logging** — but the audit log never stores secret or configmap contents.
- **Kubelet locked down** — no anonymous access, read-only port off, webhook auth, strong TLS.
- **Encrypted at rest** — secrets, etcd, and node disks.
- **Encrypted between nodes** — Cilium WireGuard (no shared key to manage).
- **No static AWS keys** — pods get access through IRSA (IAM roles).
- **Spot safety** — a node-termination handler drains pods gracefully when Spot reclaims a node.
- **metrics-server is on** — so the app's autoscaler (HPA) has CPU data to work with.

## DNS

Clusters are named under `k8s.internal` — that's ICANN's reserved TLD for private networks, so it never clashes with a real domain. They resolve only inside the VPC through a Route53 **private hosted zone** (`spec.dnsZone: k8s.internal` + `topology.dns.type: Private`), so the API is never exposed to the public internet.

If you ever did build the cluster, you'd create that zone once per account first:

```console
aws route53 create-hosted-zone --name k8s.internal \
  --hosted-zone-config PrivateZone=true \
  --vpc VPCRegion=<region>,VPCId=<vpc-id> \
  --caller-reference $(uuidgen)
```
