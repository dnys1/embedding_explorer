import * as crypto from "node:crypto";
import * as fs from "node:fs";

// getFileHash calculates a hash for all of the files under the scripts directory.
export function getFileHash(filename: string): string {
  const data = fs.readFileSync(filename, {
    encoding: "utf8",
  });
  const hash = crypto.createHash("sha256").update(data, "utf8");
  return hash.digest("base64");
}

// crawlDirectory recursive crawls the provided directory, applying the provided function
// to every file it contains. Doesn't handle cycles from symlinks.
export function crawlDirectory(dir: string, f: (_: string) => void) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const filePath = `${dir}/${file}`;
    const stat = fs.statSync(filePath);
    if (stat.isDirectory()) {
      crawlDirectory(filePath, f);
    }
    if (stat.isFile()) {
      f(filePath);
    }
  }
}
