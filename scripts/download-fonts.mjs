/**
 * download-fonts.mjs
 * Baixa as fontes DM Sans e DM Serif Display do Google Fonts
 * e salva em public/fonts/ para eliminar dependência externa.
 *
 * Executar: node scripts/download-fonts.mjs
 */

import https from 'https';
import fs   from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FONTS_DIR = path.join(__dirname, '..', 'public', 'fonts');

const FONTS = [
  // DM Sans — mesmos arquivos para weight 400 e 500 (são as variantes do subset)
  {
    url:  'https://fonts.gstatic.com/s/dmsans/v17/rP2Hp2ywxg089UriCZ2IHSeH.woff2',
    dest: 'dm-sans-latin-ext.woff2',
  },
  {
    url:  'https://fonts.gstatic.com/s/dmsans/v17/rP2Hp2ywxg089UriCZOIHQ.woff2',
    dest: 'dm-sans-latin.woff2',
  },
  // DM Serif Display — normal
  {
    url:  'https://fonts.gstatic.com/s/dmserifdisplay/v17/-nFnOHM81r4j6k0gjAW3mujVU2B2G_5x0ujy.woff2',
    dest: 'dm-serif-display-latin-ext.woff2',
  },
  {
    url:  'https://fonts.gstatic.com/s/dmserifdisplay/v17/-nFnOHM81r4j6k0gjAW3mujVU2B2G_Bx0g.woff2',
    dest: 'dm-serif-display-latin.woff2',
  },
  // DM Serif Display — italic
  {
    url:  'https://fonts.gstatic.com/s/dmserifdisplay/v17/-nFhOHM81r4j6k0gjAW3mujVU2B2G_VB3vD212k.woff2',
    dest: 'dm-serif-display-italic-latin-ext.woff2',
  },
  {
    url:  'https://fonts.gstatic.com/s/dmserifdisplay/v17/-nFhOHM81r4j6k0gjAW3mujVU2B2G_VB0PD2.woff2',
    dest: 'dm-serif-display-italic-latin.woff2',
  },
];

function download(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      if (res.statusCode === 301 || res.statusCode === 302) {
        file.close();
        fs.unlinkSync(dest);
        download(res.headers.location, dest).then(resolve).catch(reject);
        return;
      }
      if (res.statusCode !== 200) {
        reject(new Error(`HTTP ${res.statusCode} para ${url}`));
        return;
      }
      res.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
      file.on('error', reject);
    }).on('error', reject);
  });
}

async function main() {
  if (!fs.existsSync(FONTS_DIR)) {
    fs.mkdirSync(FONTS_DIR, { recursive: true });
    console.log(`✔ Criado: public/fonts/`);
  }

  for (const { url, dest } of FONTS) {
    const fullDest = path.join(FONTS_DIR, dest);
    if (fs.existsSync(fullDest)) {
      console.log(`⏭  Já existe: ${dest}`);
      continue;
    }
    process.stdout.write(`⬇  Baixando ${dest}... `);
    try {
      await download(url, fullDest);
      const size = (fs.statSync(fullDest).size / 1024).toFixed(1);
      console.log(`✔ (${size} KB)`);
    } catch (e) {
      console.log(`✗ ERRO: ${e.message}`);
      process.exit(1);
    }
  }

  console.log('\n✅ Todas as fontes baixadas em public/fonts/');
  console.log('   O site agora não depende mais do Google Fonts.\n');
}

main();
