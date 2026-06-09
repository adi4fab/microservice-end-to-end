# Ansible — application config + deploy

Ansible owns the **application configuration** (`vars/dev.yml`, `vars/prod.yml`)
and feeds it to the Helm chart, which renders the Kubernetes objects. This keeps
config-as-data in Ansible and templating in Helm.

## Layout

| File | Purpose |
| --- | --- |
| `vars/dev.yml`, `vars/prod.yml` | per-env app config (`SECRET_ID`, `AWS_REGION`, `PORT`), namespace, image tag |
| `deploy.yml` | runs `helm upgrade --install`, injecting the app config via `--set-string config.*` |
| `inventory.ini` / `ansible.cfg` | local connection (helm runs against your current kube-context) |

## Usage

```console
# requires: helm, kubectl (pointed at the target cluster), ansible
ansible-playbook deploy.yml -e env=dev
ansible-playbook deploy.yml -e env=prod
```

The app config defined here lands in a ConfigMap (rendered by Helm) and is
injected into the app container as environment variables. Secrets are **not**
stored here — the app reads them from AWS Secrets Manager via `SECRET_ID`.
