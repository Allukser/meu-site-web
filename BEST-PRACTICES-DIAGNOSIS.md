# Best Practices Score Diagnosis — 92 → 100

**Objetivo:** Identificar e resolver os 8 pontos faltantes na métrica "Best Practices" do Lighthouse.

**Métrica crítica:** A métrica "Best Practices" avalia segurança, performance standards, e boas práticas web modernas.

---

## 🔍 Como Diagnosticar Localmente

### Passo 1: Setup
```bash
# Certifique-se que está no ramo main
git status

# Instale dependências
npm install

# Build de produção
npm run build

# Preview da build (simula deployment real)
npm run preview
```

### Passo 2: Run Lighthouse (Chrome DevTools)
1. Abra a preview em Chrome: `http://localhost:3000` (porta do preview)
2. Devtools → Lighthouse
3. **Opções críticas:**
   - Mode: **Mobile**
   - Device: **Moto G4** (baseline)
   - Throttling: **Slow 4G** (mais strict)
   - Clear storage: ✅ (remove localStorage, cache)
   - Incognito: ✅ (sem extensions)
4. Click "Analyze page load"
5. Espere 60-90 segundos

### Passo 3: Documentar o Score
Na seção "Best Practices", anote:
- **Exato score:** 92/100
- **Warnings listadas:** (copy full text)
- **Errors:** (se houver)

---

## 🎯 Possíveis Culpritos (em ordem de probabilidade)

### 1️⃣ Cross-Origin Resource Sharing (CORS) Issues
**Score Impact:** 4-6 pontos  
**Sintoma:** Lighthouse report: "Missing CORS header" ou "Insecure HTTPS resource"

**Check list:**
```bash
# Inspecione _headers
cat public/_headers

# Procure por:
# ✅ Access-Control-Allow-Origin: [appropriate]
# ❌ Se falta e há cross-origin requests → problema
```

**Culprit potencial:** Worker de GCLID (`roangela-gclid.alukser.workers.dev`)
- Lighthouse pode flaggar se CORS não configurado corretamente

**Fix:**
```
# public/_headers — adicione se não houver

https://psicorosangelarocha.com/*
  Access-Control-Allow-Origin: *
  Access-Control-Allow-Methods: GET, POST, OPTIONS
```

**Validação:**
```bash
# Teste CORS
curl -I -H "Origin: https://psicorosangelarocha.com" \
  https://roangela-gclid.alukser.workers.dev/lead
  
# Procure por: Access-Control-Allow-Origin header
```

---

### 2️⃣ Content Security Policy (CSP) Warnings
**Score Impact:** 2-4 pontos  
**Sintoma:** "unsafe-inline is insecure" ou "CSP violation in console"

**Check list:**
```bash
# Inspecione CSP atual
grep "Content-Security-Policy" public/_headers

# Actual CSP:
# Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; ...

# Problemas possíveis:
# ❌ 'unsafe-inline' in script-src (GCLID tracking)
# ❌ 'unsafe-inline' in style-src (@font-face inline)
# ⚠️ connect-src permite Worker (necessary)
```

**Alternativas (futuro):**
```
# Option A: Hash-based CSP (remover unsafe-inline)
script-src 'self' 'sha256-XXXXX' (inline GCLID script)

# Option B: Externalizar scripts
# Criar /js/tracking.js (GCLID logic) → link não inline

# Option C: Service Worker
# Interceptar clicks via SW (sem unsafe-inline)
```

**Quick Fix (se necessário):**
- Se score é 92 por CSP, Lighthouse pode estar reportando warning mas não penalizando severamente
- Manter atual (funciona) ou refactor para SHA256

**Validação em DevTools:**
```javascript
// Console → execute
console.log(
  document.head.querySelector('script[type="application/ld+json"]').textContent
);
// Deve estar presente sem erros CSP
```

---

### 3️⃣ Deprecated APIs or Browser Support Issues
**Score Impact:** 1-3 pontos  
**Sintoma:** "Using deprecated API X" ou "Unsupported feature"

**Check list — JavaScript APIs**
```bash
# No Console do DevTools, procure por warnings:
# ❌ "Synchronous XMLHttpRequest deprecated" (não há sync XHR no site)
# ❌ "document.write() deprecated" (não há document.write)
# ✅ fetch() é moderno (OK)
# ✅ localStorage é suportado (OK)
# ✅ requestIdleCallback é suportado com fallback (OK)
```

**Check list — CSS**
```bash
# Inspecione styles — procure por:
# ✅ CSS Grid, Flexbox (moderno)
# ✅ CSS custom properties (moderno)
# ❌ -webkit- prefixes desnecessários?
# ❌ IE10 hacks?
```

**Fix (se encontrado):**
```bash
# Atualize Astro (remove legacy polyfills)
npm upgrade astro@latest

# Ou remova CSS prefixes desnecessários de global.css
```

---

### 4️⃣ Third-party Code or Ads Policy
**Score Impact:** 2-3 pontos  
**Sintoma:** "Third-party script blocks main thread" ou "Ad-related warning"

**Check list:**
```bash
# Procure no HTML final (na build) por:
grep -r "google-analytics" dist/
grep -r "googletagmanager" dist/
grep -r "facebook.com" dist/
grep -r "doubleclick" dist/
grep -r "adsense" dist/

# Se nenhum encontrado → não é problema de third-party ads
```

**Culprits possíveis:**
- Script de GCLID inline (verificado em CSP above)
- Nenhum Google Analytics detectado (bom!)
- Nenhum ads network detectado (bom!)

**Conclusão:** Improvável ser o culprit se grep retorna nada.

---

### 5️⃣ Image Format or Size Issues
**Score Impact:** 1-2 pontos  
**Sintoma:** "Image is not responsive" ou "Image should be WebP"

**Check list — Assets**
```bash
# Inspecione images na build
ls -lh public/*.{svg,png,jpg,webp} 2>/dev/null

# Encontrado:
# - public/og-image.svg (1200×630)
# - public/favicon.svg
# - Nenhuma imagem no hero? (lazy load)

# Procure por imagens inline em Astro components
grep -r "img" src/components/
# Se há imagens, são SVG? (melhor) ou raster? (talvez WebP?)
```

**Fix (se aplicável):**
```bash
# 1. Minificar SVGs
npm install -D svgo
npx svgo public/og-image.svg --output public/og-image.min.svg

# 2. Se houver JPGs/PNGs, converter para WebP
# npm install -D sharp
```

---

### 6️⃣ Lighthouse Version Mismatch
**Score Impact:** 0-2 pontos (variação de versão)  
**Sintoma:** Score varia +/- 3 pontos entre runs mesmo sem mudanças

**Explicação:**
- Cada versão do Chrome/Lighthouse tem critérios ligeiramente diferentes
- Versão atual do Chrome pode estar diferente da CI/CD

**Check:**
```bash
# Chrome local version
google-chrome --version

# Ou no DevTools → 3 dots → About
```

**Fix (não necessário):**
- Score 92 é consistente em múltiplos runs? (OK, não é variação)
- Score muda entre runs? (possível Lighthouse update ou sistema lag)

---

### 7️⃣ HTTPS or Protocol Warnings
**Score Impact:** 1-2 pontos  
**Sintoma:** "Mixed content" ou "Insecure resource"

**Check list:**
```bash
# Inspecione all resources em Network tab
# Procure por:
# ✅ https://psicorosangelarocha.com (HTTPS)
# ✅ https://roangela-gclid.alukser.workers.dev (HTTPS)
# ✅ /fonts/*.woff2 (HTTPS, local)
# ❌ http:// (sem S) — PROBLEMA

# Command line check:
grep -r "http://" src/ public/ | grep -v "https://"
# Se encontra "http://" é problema
```

**Fix (se necessário):**
```bash
# Procure e replace http:// → https://
# Layout.astro, components, etc.

# Astro config
cat astro.config.mjs
# Verificar se site URL usa https://
```

---

### 8️⃣ Manifest or PWA Issues
**Score Impact:** 1-2 pontos  
**Sintoma:** "Missing web app manifest" ou "Manifest is not valid"

**Check list:**
```bash
# Procure por manifest.json
ls -la public/manifest.json 2>/dev/null

# Procure por link no Layout
grep "manifest" src/layouts/Layout.astro

# Se falta: não é problema crítico (PWA não é obrigatório)
# Score de 92 sugere que manifest não é o culprit
```

---

## 🔍 Como Rodar Diagnóstico Passo a Passo

### Scenario: Você está vendo score 92 no PageSpeed Insights

**Passo 1: Reproduzir localmente**
```bash
npm run build
npm run preview
# Abra DevTools → Lighthouse
# Run com mesmas settings do PSI (mobile, slow 4G, clear storage)
```

**Passo 2: Coletar warnings**
```
✏️ Anote EXATAMENTE o que Lighthouse reporta em "Best Practices"
Exemplo:
- ⚠️ "Cross-Origin Resource Sharing (CORS) issue"
- ⚠️ "Content Security Policy (CSP) violation"
```

**Passo 3: Cross-reference com checklist acima**
- Use Ctrl+F para procurar pelo warning
- Siga o Fix recomendado

**Passo 4: Validar com DevTools Console**
```javascript
// Procure por erros de warning
console.log(document.body.innerHTML);
// Há console warnings? Lighthouse os reporta.
```

---

## 📋 Decision Tree (Rápido)

```
Score 92 → Faltam 8 pontos

Vejo warnings específicos?
├─ SIM → Vá para checklist de número correspondente (1-8 acima)
└─ NÃO → Lighthouse pode estar reportando múltiplos mini-issues

Rodei audit 3x e score é consistente 92?
├─ SIM → É problema real (não variação de sistema)
└─ NÃO → Pode ser cache/system lag

Consegui localizar o culprit?
├─ SIM → Apply fix, rebuild, audit novamente
└─ NÃO → Escalate (pode ser subtle CSP ou Lighthouse version issue)
```

---

## 🚀 Implementation Checklist

- [ ] Run Lighthouse localmente (mobile, slow 4G, clear storage)
- [ ] Document exato warning/error
- [ ] Identify culprit usando checklist acima
- [ ] Apply fix sugerido
- [ ] Rebuild e audit novamente
- [ ] Validar score 100/100
- [ ] Commit com mensagem: `fix(best-practices): resolve [specific issue]`
- [ ] Push para main e validar no PageSpeed Insights

---

## 🆘 Se Preso

Se nenhum dos 8 culprits acima se aplica:

1. **Inspecione DOM no DevTools**
   - Elements tab → procure por elementos com `data-lighthouse-*` (debug markers)
   - Console → há warnings/errors?

2. **Lighthouse report JSON**
   ```javascript
   // DevTools Console
   // Copia full report (copy object)
   // Salve como lighthouse-report.json
   ```

3. **Comparar com site de controle**
   - Execute audit em site 100/100 (ex: example.com)
   - Compare a estrutura vs seu site

4. **Atualizar Astro**
   ```bash
   npm upgrade astro@latest
   npm run build && npm run preview
   # Audit novamente
   ```

---

**Próxima ação:** Rodar Lighthouse audit agora e documentar exato warning! 🚀
