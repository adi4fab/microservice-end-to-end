import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";

// loadConfig resolves runtime configuration.
//
// Primary source is AWS Secrets Manager: when SECRET_ID is set, the named secret
// must hold a JSON object such as {"S3_BUCKET":"my-bucket","AWS_REGION":"us-east-1"}.
// AWS_REGION (env) is the bootstrap region used to reach Secrets Manager, and
// also the default S3 region if the secret omits one.
//
// If SECRET_ID is not set, the same values fall back to plain environment
// variables, which keeps local development simple. PORT is always env-driven
// and defaults to 8080.
export async function loadConfig() {
  const port = parseInt(process.env.PORT || "8080", 10);
  const bootstrapRegion = process.env.AWS_REGION || "us-east-1";

  let bucket = process.env.S3_BUCKET || "";
  let region = bootstrapRegion;

  const secretId = process.env.SECRET_ID;
  if (secretId) {
    const sm = new SecretsManagerClient({ region: bootstrapRegion });
    const res = await sm.send(new GetSecretValueCommand({ SecretId: secretId }));
    const secret = JSON.parse(res.SecretString || "{}");
    bucket = secret.S3_BUCKET || bucket;
    region = secret.AWS_REGION || region;
  }

  if (!bucket) {
    throw new Error(
      "S3 bucket not configured: set SECRET_ID (Secrets Manager) or S3_BUCKET"
    );
  }

  return { port, bucket, region, maxUploadBytes: 10 * 1024 * 1024 };
}
