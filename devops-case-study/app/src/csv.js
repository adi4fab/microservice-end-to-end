import { parse } from "csv-parse/sync";
import path from "node:path";

// parseAndSanitize reads a CSV buffer and returns its rows with every cell
// sanitized against CSV formula injection. The sample format has no header and
// three columns (id, name, price) but we accept a variable column count so the
// parser stays useful for other exports.
export function parseAndSanitize(buffer) {
  const records = parse(buffer, {
    relax_column_count: true, // do not enforce a fixed number of columns
    trim: true,
    skip_empty_lines: true,
  });
  return records.map((row) => row.map(sanitizeCell));
}

// sanitizeCell neutralizes CSV/formula injection: spreadsheet apps treat a cell
// beginning with = + - @ (or tab/CR) as a formula. We prefix a single quote so
// the value is stored/rendered literally instead of executed if the file is
// reopened in Excel/Sheets. (Browser output is additionally escaped by EJS,
// which guards against XSS.)
export function sanitizeCell(value) {
  const s = String(value ?? "").trim();
  if (s.length === 0) return s;
  if (["=", "+", "-", "@", "\t", "\r"].includes(s[0])) {
    return "'" + s;
  }
  return s;
}

// isCSV reports whether a filename looks like a CSV upload.
export function isCSV(name) {
  return path.extname(name || "").toLowerCase() === ".csv";
}

// safeName strips directory components to prevent path traversal when building
// the storage key.
export function safeName(name) {
  const base = path.basename(name || "");
  return base && base !== "." ? base : "upload.csv";
}
