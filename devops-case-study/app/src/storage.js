import {
  S3Client,
  PutObjectCommand,
  ListObjectsV2Command,
  HeadBucketCommand,
} from "@aws-sdk/client-s3";

const PROCESSED_PREFIX = "processed/";

// S3Storage targets real AWS S3. Credentials come from the default AWS provider
// chain: IRSA (IAM Roles for Service Accounts) in-cluster, and the shared
// config/SSO/env chain locally. No keys are embedded in the app.
export class S3Storage {
  constructor({ bucket, region }) {
    this.bucket = bucket;
    this.client = new S3Client({ region });
  }

  // save uploads the original CSV under a timestamped key.
  async save(key, body, contentType = "text/csv") {
    await this.client.send(
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: key,
        Body: body,
        ContentType: contentType,
      })
    );
  }

  // list returns previously processed files, most recent first.
  async list() {
    const out = await this.client.send(
      new ListObjectsV2Command({ Bucket: this.bucket, Prefix: PROCESSED_PREFIX })
    );
    const files = (out.Contents || []).map((obj) => ({
      name: obj.Key.replace(PROCESSED_PREFIX, ""),
      size: obj.Size ?? 0,
      modified: obj.LastModified ?? new Date(0),
    }));
    files.sort((a, b) => b.modified - a.modified);
    return files;
  }

  // ping verifies the bucket is reachable, for readiness checks.
  async ping() {
    await this.client.send(new HeadBucketCommand({ Bucket: this.bucket }));
  }
}

export { PROCESSED_PREFIX };
