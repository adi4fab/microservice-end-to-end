import express from "express";
import helmet from "helmet";
import multer from "multer";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadConfig } from "./config.js";
import { S3Storage } from "./storage.js";
import { parseAndSanitize, isCSV, safeName } from "./csv.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

let config;
try {
  config = await loadConfig();
} catch (err) {
  log("error", "config load failed", { err: err.message });
  process.exit(1);
}

const store = new S3Storage({ bucket: config.bucket, region: config.region });

// Keep uploads in memory (capped) — we parse and forward to S3, never to disk.
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: config.maxUploadBytes, files: 1 },
});

const app = express();
app.disable("x-powered-by");
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// Conservative security headers for a server-rendered app (no inline JS).
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'"],
        imgSrc: ["'self'"],
        scriptSrc: ["'none'"],
        objectSrc: ["'none'"],
        frameAncestors: ["'none'"],
      },
    },
  })
);

// Minimal structured request log.
app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    log("info", "request", {
      method: req.method,
      path: req.path,
      status: res.statusCode,
      ms: Date.now() - start,
    });
  });
  next();
});

app.use("/static", express.static(path.join(__dirname, "..", "public")));

app.get("/healthz", (_req, res) => res.type("text").send("ok"));

app.get("/readyz", async (_req, res) => {
  try {
    await store.ping();
    res.type("text").send("ready");
  } catch {
    res.status(503).type("text").send("storage unavailable");
  }
});

app.get("/", async (_req, res) => {
  const files = await safeList();
  res.render("index", view({ files }));
});

app.post("/upload", upload.single("file"), async (req, res) => {
  if (!req.file) {
    return res.status(400).render("index", view({ files: await safeList(), error: "Please choose a CSV file to upload." }));
  }
  if (!isCSV(req.file.originalname)) {
    return res.status(415).render("index", view({ files: await safeList(), error: "Only .csv files are accepted." }));
  }

  let rows;
  try {
    rows = parseAndSanitize(req.file.buffer);
  } catch (err) {
    return res.status(400).render("index", view({ files: await safeList(), error: "Could not parse CSV: " + err.message }));
  }

  // Printing the parsed rows is independent of archiving: we always show the
  // content, and only warn if the S3 upload fails.
  const key = `processed/${timestamp()}-${safeName(req.file.originalname)}`;
  let archived = true;
  let archiveErr = "";
  try {
    await store.save(key, req.file.buffer);
  } catch (err) {
    archived = false;
    archiveErr = err.message;
    log("error", "save to storage failed", { err: err.message, key });
  }

  res.render(
    "index",
    view({
      files: await safeList(),
      rows,
      name: req.file.originalname,
      count: rows.length,
      message: archived ? `Processed ${rows.length} rows and archived to ${key}.` : "",
      error: archived ? "" : `Processed ${rows.length} rows, but archiving to S3 failed: ${archiveErr}`,
    })
  );
});

// Multer/body errors (e.g. file too large) surface here.
app.use((err, _req, res, _next) => {
  log("error", "request error", { err: err.message });
  res.status(400).render("index", view({ files: [], error: err.message }));
});

const server = app.listen(config.port, () => {
  log("info", "listening", { port: config.port, bucket: config.bucket });
});

// Graceful shutdown for Kubernetes rollouts.
for (const sig of ["SIGINT", "SIGTERM"]) {
  process.on(sig, () => {
    log("info", "shutting down", { signal: sig });
    server.close(() => process.exit(0));
  });
}

// ---- helpers --------------------------------------------------------------

function view(data) {
  return { rows: null, name: "", count: 0, message: "", error: "", files: [], ...data };
}

async function safeList() {
  try {
    return await store.list();
  } catch (err) {
    log("error", "list files failed", { err: err.message });
    return [];
  }
}

function timestamp() {
  return new Date().toISOString().replace(/[-:]/g, "").replace(/\..+/, "Z");
}

function log(level, msg, fields = {}) {
  console.log(JSON.stringify({ level, msg, ...fields, time: new Date().toISOString() }));
}
