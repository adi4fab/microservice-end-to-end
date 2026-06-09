# Architecture

DevOps case study — a hardened CSV-processor web app on Kubernetes, with
multi-account AWS infrastructure (Terragrunt), Helm/Ansible delivery, and a
kops cluster definition.

## 1. Runtime request flow (the pod + AWS)

Nginx and the app run in **one pod**, sharing static assets through an in-pod
**emptyDir** (not NFS). Nginx serves `/static/` from that volume and proxies
everything else to the app, which talks to AWS.

```mermaid
flowchart LR
  user([User]) -->|HTTP| svc[Service]

  subgraph pod["Pod: csv-processor"]
    init["initContainer<br/>copy-static"]
    vol[("emptyDir<br/>static-assets")]
    nginx["nginx :8081"]
    app["app :8080<br/>Node/Express"]
  end

  svc --> nginx
  init -. "copies public/" .-> vol
  nginx -->|"/static/"| vol
  nginx -->|"/, /upload (proxy)"| app

  app -->|"get config"| sm[("Secrets Manager")]
  app -->|"PutObject / List<br/>SSE-KMS"| s3[("S3 bucket")]
  s3 -. "encrypt at rest" .-> kms[("KMS CMK")]
  s3 -. "lifecycle: 30d" .-> glacier[("Glacier")]
```

## 2. Multi-account / multi-region infrastructure (Terragrunt)

Each environment is a **separate AWS account**. Terragrunt provisions the same
units per account, named `<env>-<region_short>-csv-processor`.

```mermaid
flowchart TB
  tg["Terragrunt<br/>run --all apply"]

  subgraph dev["dev account 311212293512 · us-west-1"]
    ds3["S3: dev-usw1-csv-processor<br/>versioned · TLS-only · Glacier"]
    dkms["KMS CMK"]
    dsec["Secret: dev-usw1-csv-processor"]
    ds3 -. SSE-KMS .-> dkms
  end

  subgraph prod["prod account 946299734469 · us-east-1"]
    ps3["S3: prod-use1-csv-processor<br/>versioned · TLS-only · Glacier"]
    pkms["KMS CMK"]
    psec["Secret: prod-use1-csv-processor"]
    ps3 -. SSE-KMS .-> pkms
  end

  tg --> dev
  tg --> prod
```

State is **per region** (`<env>-<region_short>-s3-tf-state`) for DR isolation.

## 3. Delivery: build → push → Ansible → Helm → cluster

The image is built once and pushed to DockerHub. **Ansible** owns the per-env
application config and invokes **Helm**, which renders the Kubernetes objects.

```mermaid
flowchart LR
  build["docker build"] -->|push| dh[("DockerHub<br/>never4ade/csv-processor")]

  ansible["Ansible deploy.yml<br/>vars/&lt;env&gt;.yml (app config)"] -->|"helm upgrade --install"| helm["Helm chart<br/>values-&lt;env&gt;.yaml"]
  helm -->|renders| objs["Deployment · Service · HPA<br/>ConfigMaps · SA · NetworkPolicy"]
  dh -. image pull .-> objs
  objs --> cluster[("kind (demo) /<br/>kops cluster (prod path)")]
```

## 4. kops cluster topology (per environment)

Self-managed Kubernetes on EC2 (not EKS). Control plane runs on instances we
own; workloads spread across on-demand, Spot, and mixed node groups, all behind
the cluster autoscaler.

```mermaid
flowchart TB
  subgraph cp["Control plane (private)"]
    m1["control-plane<br/>etcd + API"]
  end
  subgraph nodes["Node groups (autoscaled)"]
    n1["nodes-ondemand"]
    n2["nodes-spot<br/>mixed types, 100% Spot"]
    n3["nodes-mixed<br/>on-demand base + Spot"]
  end
  ca["cluster-autoscaler"] --> n1 & n2 & n3
  bastion["bastion"] --> cp
  cp --> nodes
```

> dev = 1 control-plane (us-west-1, 2 AZs); prod = 3 control-plane HA (us-east-1, 3 AZs).

## Security highlights

| Layer | Controls |
| --- | --- |
| App | CSV formula-injection sanitization, output escaping (anti-XSS), upload limits, helmet/CSP |
| Image/pod | non-root (uid 1000), read-only rootfs, dropped capabilities, seccomp, NetworkPolicy |
| AWS | SSE-KMS, block-public-access, versioning, TLS-only bucket policy, Secrets Manager (no static keys), IRSA |
| Cluster (kops) | IMDSv2, private topology, audit logging, kubelet CIS hardening, etcd/secrets encryption, Cilium WireGuard |

## Component map

| Path | What |
| --- | --- |
| `app/` | Node.js/Express CSV processor (Docker image) |
| `helm/csv-processor/` | Helm chart + `values-dev/prod` |
| `ansible/` | per-env app config + deploy playbook |
| `kops/dev`, `kops/prod` | kops cluster definitions |
| `IAC-terragrunt/` | S3 + KMS + Secrets Manager per account/region |
