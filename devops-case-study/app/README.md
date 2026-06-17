# CSV Processor

A small, hardened **Node.js (Express)** web app that:

1. accepts a **CSV upload**,
2. parses it and **prints the rows in the browser**,
3. **archives the original file to S3**, and
4. lists **previously processed files** from the bucket.

Built for the DevOps case study. Runs as a non-root container on Kubernetes,
authenticating to S3 via **IRSA** in-cluster (no static keys) and the standard
AWS credential chain locally.

## Layout

```
app/
├── package.json / package-lock.json
├── src/
│   ├── server.js     # Express app: routes, helmet, multer, graceful shutdown
│   ├── config.js     # env-driven configuration
│   ├── csv.js        # CSV parsing + formula-injection sanitization
│   ├── storage.js    # S3 backend (AWS SDK v3)
│   └── views/        # EJS templates (auto-escaped → anti-XSS)
├── public/           # CSS
└── Dockerfile        # multi-stage → node:22-alpine, non-root
```

## Configuration (env vars)

| Variable | Default | Notes |
| --- | --- | --- |
| `S3_BUCKET` | `REPLACE_ME_BUCKET` | **Set this** to your bucket name |
| `AWS_REGION` | `us-east-1` | Bucket region |
| `PORT` | `8080` | HTTP listen port |

AWS credentials are resolved by the default SDK chain:
- **In-cluster:** IRSA (a ServiceAccount annotated with an IAM role).
- **Locally:** your `~/.aws` profile / env vars / SSO.

## Run locally (Docker)

> Requires an existing S3 bucket and AWS credentials. The app picks its config
> source from the env: if `SECRET_ID` is set it reads `{S3_BUCKET, AWS_REGION}`
> from AWS Secrets Manager; otherwise it reads `S3_BUCKET` + `AWS_REGION` directly.

```sh
docker build -t csv-processor:dev .
```

### Provide credentials

For an AWS SSO profile (temporary creds), export them into a file the container
reads (works without baking keys into the image):

```sh
aws sso login --profile dev          # if the session has expired
aws configure export-credentials --profile dev --format env-no-export > /tmp/dev-aws.env
```

### A) Plain env (no Secrets Manager)

Bucket and region are passed directly.

```sh
docker run --rm -p 8080:8080 --env-file /tmp/dev-aws.env \
  -e S3_BUCKET=dev-usw1-csv-processor \
  -e AWS_REGION=us-west-1 \
  csv-processor:dev
```

### B) Via AWS Secrets Manager

Bucket/region come from the secret; only `SECRET_ID` (+ a bootstrap `AWS_REGION`
to reach Secrets Manager) is passed.

```sh
docker run --rm -p 8080:8080 --env-file /tmp/dev-aws.env \
  -e SECRET_ID=dev-usw1-csv-processor \
  -e AWS_REGION=us-west-1 \
  csv-processor:dev
```

```sh
rm /tmp/dev-aws.env    # short-lived creds — delete when done
```

`AWS_REGION` is required in both modes (the bucket region in A; the Secrets
Manager region + default S3 region in B). In-cluster these creds come from IRSA
instead of the exported file.

Open <http://localhost:8080>, upload a CSV (e.g. the provided `soh.csv`).

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/` | Upload form + list of processed files |
| POST | `/upload` | Process a CSV, render rows, archive to S3 |
| GET | `/healthz` | Liveness probe |
| GET | `/readyz` | Readiness probe (checks the bucket is reachable) |
| GET | `/static/*` | Static assets |

## Security notes

- **CSV formula injection**: cells beginning with `= + - @` (or tab/CR) are
  prefixed with `'` before display/storage.
- **XSS**: all output is rendered through EJS (`<%= %>`), which auto-escapes.
- **Upload limits**: in-memory, single file, capped at 10 MiB; only `.csv`.
- **Path traversal**: storage keys are built from a sanitized basename.
- **HTTP hardening**: `helmet` (CSP, HSTS, frame-deny, nosniff), `x-powered-by`
  disabled, no inline scripts.
- **Container**: `node:22-alpine`, non-root `node` user, prod-only deps.
