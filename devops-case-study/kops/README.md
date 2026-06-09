# kops cluster config (dev + prod)

Kubernetes cluster definitions for **kops** on AWS — one per environment. These
are **config artifacts** (the case study doesn't require a running cluster), so
they're written and validated, not applied.

> **Validated** with **kops 1.35.1** — `kops create -f` (schema) + `kops update
> cluster` dry-run (full semantic validation incl. live AWS zone/AMI lookups) —
> both clusters pass with no errors. Kubernetes `v1.35.5` (latest stable on the
> kops 1.35 channel).

## Layout

```
kops/
├── dev/    microsvc-dev.k8s.internal   (us-west-1, 1 control-plane, 2 AZs)
└── prod/   microsvc-prod.k8s.internal  (us-east-1, 3 control-plane HA, 3 AZs)
```

Each env folder has: `cluster.yaml`, `ig-control-plane.yaml`, and three node
groups — `ig-nodes-ondemand.yaml`, `ig-nodes-spot.yaml`, `ig-nodes-mixed.yaml`.

| | dev | prod |
| --- | --- | --- |
| Region | us-west-1 (a, c) | us-east-1 (a, b, c) |
| Control plane | 1 (cost-saving, non-HA) | 3 (HA etcd quorum) |
| State store | `s3://microsvc-dev-kops-state` | `s3://microsvc-prod-kops-state` |
| Node group sizes | smaller min/max | prod-sized |

## How the requirements map (both envs)

| Requirement | Where |
| --- | --- |
| Multiple instance groups | control-plane + 3 node groups |
| Mixed instance group | `mixedInstancesPolicy` in `nodes-spot` and `nodes-mixed` |
| Lifecycle: spot **and** on-demand | `nodes-ondemand` (on-demand), `nodes-spot` (Spot), `nodes-mixed` (both) |
| Cluster autoscaler for all node IGs | `spec.clusterAutoscaler.enabled` + per-node-IG discovery labels + `minSize != maxSize` |

## Security hardening (FAANG / prod-grade)

| Control | What & why |
| --- | --- |
| **IMDSv2 enforced** (every IG) | `httpTokens: required`, hop limit `1` — blocks pod-SSRF → node-credential theft. |
| **Private topology + bastion** | No public control-plane/nodes; private API DNS. |
| **API/SSH locked to `10.0.0.0/8`** | not `0.0.0.0/0`. |
| **API audit logging** | policy never records secret/configmap contents; full request+response on RBAC. |
| **Kubelet hardening (CIS)** | anon auth off, read-only port `0`, webhook authn/authz, `protectKernelDefaults`, strong TLS ciphers. |
| **Secrets + etcd + EBS encryption** | `encryptionConfig`, encrypted etcd volumes, `rootVolumeEncryption`. |
| **In-cluster encryption** | Cilium WireGuard (keyless). |
| **IRSA (no static keys)** | OIDC provider + `useServiceAccountExternalPermissions`. |
| **Spot safety** | node-termination-handler drains pods on the 2-min notice. |
| **metrics-server** | so the app's HPA has metrics. |

## Prerequisites & deploy (per environment)

```console
brew install kops

# pick an environment
export ENV=dev          # or prod
export NAME=microsvc-$ENV.k8s.internal
export KOPS_STATE_STORE=s3://microsvc-$ENV-kops-state

# state + OIDC discovery buckets (in that account)
aws s3 mb s3://microsvc-$ENV-kops-state
aws s3 mb s3://microsvc-$ENV-oidc-store

# required runtime secrets (kept out of git)
kops create secret --name $NAME sshpublickey admin -i ~/.ssh/id_ed25519.pub

KEY=$(head -c 32 /dev/urandom | base64)
cat > /tmp/encryptionconfig.yaml <<EOF
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources: ["secrets"]
    providers:
      - aescbc: { keys: [ { name: key1, secret: ${KEY} } ] }
      - identity: {}
EOF
kops create secret --name $NAME encryptionconfig -f /tmp/encryptionconfig.yaml

# register + (dry-run) + build + validate + destroy
kops create -f $ENV/cluster.yaml
kops create -f $ENV/ig-control-plane.yaml
kops create -f $ENV/ig-nodes-ondemand.yaml
kops create -f $ENV/ig-nodes-spot.yaml
kops create -f $ENV/ig-nodes-mixed.yaml
kops update cluster $NAME            # dry run (config-only check)
kops update cluster $NAME --yes      # build it (omitted for the case study)
kops validate cluster --wait 10m
kops delete cluster $NAME --yes
```

## Notes

- Cilium encryption uses **WireGuard** (keyless) — no `ciliumpassword` secret needed.
- **DNS is real & private** — clusters are named under `k8s.internal` (ICANN's
  reserved private-use TLD) and resolve only inside the VPC via a Route53
  **private hosted zone** (`spec.dnsZone: k8s.internal` + `topology.dns.type:
  Private`). The API is reached through the bastion/VPN, never the public
  internet. Create the zone once per account before applying:
  `aws route53 create-hosted-zone --name k8s.internal --hosted-zone-config PrivateZone=true --vpc VPCRegion=<region>,VPCId=<vpc-id> --caller-reference $(uuidgen)`.
- `dev` is single-control-plane to save cost; `prod` runs 3 for etcd HA quorum.
  us-west-1 only exposes 2 AZs, so dev spreads nodes across `us-west-1a`/`us-west-1c`.
