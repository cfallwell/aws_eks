import { cpSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const appRoot = path.resolve(__dirname, "..");
const chartRoot = path.resolve(appRoot, "../../charts/spa-demo/files");
const runtimeDir = path.join(chartRoot, "runtime");
const siteDir = path.join(chartRoot, "site");
const assetsDir = path.join(siteDir, "assets");
const imagesDir = path.join(siteDir, "images");
const chunkSize = 180_000;

mkdirSync(runtimeDir, { recursive: true });
mkdirSync(assetsDir, { recursive: true });
mkdirSync(imagesDir, { recursive: true });

for (const entry of readdirSync(runtimeDir)) {
  if (entry.startsWith("server.js.part.")) {
    rmSync(path.join(runtimeDir, entry), { force: true });
  }
}

rmSync(path.join(runtimeDir, "server.js"), { force: true });

cpSync(path.join(appRoot, "dist/index.html"), path.join(siteDir, "index.html"));
cpSync(path.join(appRoot, "dist/assets/app.js"), path.join(assetsDir, "app.js"));

for (const entry of readdirSync(imagesDir)) {
  rmSync(path.join(imagesDir, entry), { force: true });
}

cpSync(path.join(appRoot, "dist/images"), imagesDir, { recursive: true });

const serverBundle = readFileSync(path.join(appRoot, "dist/server.js"), "utf8");
const chunkCount = Math.ceil(serverBundle.length / chunkSize);

for (let index = 0; index < chunkCount; index += 1) {
  const start = index * chunkSize;
  const end = start + chunkSize;
  const chunk = serverBundle.slice(start, end);
  const fileName = `server.js.part.${String(index).padStart(3, "0")}`;
  writeFileSync(path.join(runtimeDir, fileName), chunk);
}
