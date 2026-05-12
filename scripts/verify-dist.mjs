import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const pagesDir = path.join(root, "src", "pages");
const indexHtml = path.join(root, "dist", "index.html");

if (!fs.existsSync(pagesDir)) {
  console.error(
    "[verify-dist] Falta a pasta src/pages. Confirme que fez push de todo o src/ e que em Cloudflare Pages o Root directory aponta para a pasta do package.json (geralmente / ou vazio).",
  );
  process.exit(1);
}

if (!fs.existsSync(indexHtml)) {
  console.error(
    "[verify-dist] Falta dist/index.html após o build. O Astro não gerou a página inicial — veja avisos sobre src/pages no log do build.",
  );
  process.exit(1);
}

console.log("[verify-dist] OK: src/pages presente e dist/index.html gerado.");
