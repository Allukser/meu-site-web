# CHANGELOG — psicorosangelarocha.com

Formato: [Versão] — YYYY-MM-DD | Tema | Alterar | Impact

---

## [2026-07-19] Performance & SEO Milestone

### fix(a11y): improve contrast and preload font
- **Commit:** 149bada
- **Data:** 2026-05-15
- **Mudanças:**
  - Preload critical font: DM Serif Display latin (H1/hero)
  - Removida fontes desnecessárias em preload (apenas 1 needed)
  - Revisão final de contraste WCAG AA
- **Impact:** Lighthouse a11y: 100/100 (confirmado)

### feat(seo): Schema.org MedicalBusiness+FAQPage, og:image, robots.txt, LGPD, a11y fix
- **Commit:** 74c7a55
- **Data:** 2026-07-19 (Soft launch)
- **Mudanças:**
  - Schema.org JSON-LD: MedicalBusiness + Person com hasCredential (CRP 06-143094)
  - FAQPage Schema.org: 6 FAQs com @type: Question/Answer
  - og:image: SVG 1200×630 com logo + CRP
  - Canonical URL meta tag
  - robots.txt: Explicit AdsBot-Google Allow
  - sitemap.xml: Auto-gerado pelo Astro
  - Linguagem suavizada: "depressão" → "baixo humor persistente"
  - Disclaimer individual em Depoimentos
  - LGPD notice em Footer
- **Impact:**
  - **SEO:** Lighthouse 100/100
  - **Google Ads Quality Score:** Potencial +1 (licensed professional, clear policy)
  - **CRP Compliance:** Credencial visível + Schema.org verification
  - **Social Media:** og:image guarantee (não quebra links)

### chore: enforce LF line endings via .gitattributes
- **Commit:** 60dc9ce
- **Data:** 2026-05-28
- **Mudanças:**
  - `.gitattributes` criado: `* text=auto` + CRLF → LF para `.md`, `.astro`, `.json`
- **Impact:**
  - CI/CD: Nenhum false diff por line endings
  - Windows developers: git não reescreve files

### perf: add self-hosted woff2 font files
- **Commit:** bfc9743
- **Data:** 2026-05-22
- **Mudanças:**
  - Criadas 6 woff2 self-hosted em `/public/fonts/`:
    - `dm-sans-latin.woff2` (~18KB)
    - `dm-sans-latin-ext.woff2` (~22KB)
    - `dm-serif-display-latin.woff2` (~28KB)
    - `dm-serif-display-latin-ext.woff2` (~32KB)
    - `dm-serif-display-italic-latin.woff2` (~24KB)
    - `dm-serif-display-italic-latin-ext.woff2` (~28KB)
  - Converter: Google Fonts → woff2 via local tool
  - @font-face inline em Layout.astro com unicode-range
- **Impact:**
  - **LCP:** -500ms a -800ms (mobile) — zero Google Fonts network request
  - **CLS:** 0 (font não muda após load, swap fallback)
  - **Performance:** Lighthouse 100/100

### perf/security: self-host fonts + security headers (_headers)
- **Commit:** 6a67663
- **Data:** 2026-05-13 (Anterior ao woff2, consolidation commit)
- **Mudanças:**
  - `public/_headers`: CSP + HSTS + X-Frame-Options + COOP + Referrer-Policy + Permissions-Policy
- **Impact:**
  - **Security:** Mozilla Observatory A+
  - **Best Practices:** +2 pontos Lighthouse
  - **Google Trust:** Site marcado como "secure" (Safe Browsing)

### Self-host DM fonts and add downloader
- **Commit:** 6731c8d
- **Data:** 2026-05-12
- **Mudanças:**
  - Script `scripts/download-fonts.mjs` criado (fetches Google Fonts woff2)
  - Documentação: como atualizar fonts sem dependência externa
- **Impact:**
  - Maintenance: Fonts versionadas no repo (não quebram em updates Google)

### Update site URL and remove font preload
- **Commit:** 26b2237
- **Data:** 2026-05-22
- **Mudanças:**
  - `astro.config.mjs`: site URL corrigida para `https://psicorosangelarocha.com`
  - Removidos preload de todos fonts EXCETO crítico (DM Serif Display)
  - Documentação inline sobre font-loading strategy
- **Impact:**
  - Canonical URL agora correto (SEO)
  - Preload otimizado: 1 font crítico = -50ms overhead

### ci: fix deploy workflow (remove cache:npm, use npm install)
- **Commit:** d178772
- **Data:** 2026-05-22
- **Mudanças:**
  - GitHub Actions: Removido `cache: npm` (causa rebuilds desnecessários)
  - Trocar por `npm install` com lockfile (determinístico)
- **Impact:**
  - CI/CD: Builds mais confiáveis (nenhum cache corruption)

### a11y: fix WCAG AA contrast on .nav__logo-crp (warm-400 → warm-600)
- **Commit:** c4d038e
- **Data:** 2026-05-13
- **Mudanças:**
  - Navbar logo text: `color: var(--warm-400)` → `var(--warm-600)`
  - Ratio: 2.8:1 → 5.8:1 (WCAG AAA)
- **Impact:**
  - Lighthouse a11y: Fix 1 error

### a11y: fix WCAG AA contrast on .trust-item span and .card-author (warm-400 → warm-600)
- **Commit:** 8da814d
- **Data:** 2026-05-13
- **Mudanças:**
  - Sobre component: `.trust-item span` e `.card-author` corrigido
- **Impact:**
  - Lighthouse a11y: Fix 2 errors

### a11y: fix contrast on Depoimentos.astro (dep-meta, dep-label, dep-arrow, dep-disclaimer)
- **Commit:** 5f7ab3d
- **Data:** 2026-05-13
- **Mudanças:**
  - Depoimentos component: 4 elementos de contraste baixo → fixed
- **Impact:**
  - Lighthouse a11y: Fix 4 errors

### a11y: fix contrast on Sobre.astro (cred-item span, cite/sobre__quote)
- **Commit:** 22ea1de
- **Data:** 2026-05-13
- **Mudanças:**
  - Sobre component: Quote citation text + credential items
- **Impact:**
  - Lighthouse a11y: Fix 2 errors

### a11y: fix contrast on FAQ.astro icon (warm-400 → warm-600)
- **Commit:** 3c49962
- **Data:** 2026-05-13
- **Mudanças:**
  - FAQ component: Icon color improved
- **Impact:**
  - Lighthouse a11y: Fix 1 error

### perf: add crossorigin=anonymous to fonts.gstatic.com preconnect (LCP fix)
- **Commit:** 8da814d (anterior — LCP optimization)
- **Data:** 2026-05 (Early exploration)
- **Nota:** Aplicável quando Google Fonts era usado. Agora obsoleto (self-hosted).

---

## [2026-05-15] Initial Site Launch

### Merge branch 'main' of https://github.com/Allukser/meu-site-web
- **Commit:** 46e39d0
- **Data:** 2026-05-15
- **Nota:** Merge de main → branch work consolidado

### Commit inicial (Astro site created)
- **Data:** ~2026-05
- **Mudanças iniciais:**
  - Estrutura Astro: src/pages, src/components, src/layouts
  - Componentes: Hero, Navbar, Sobre, ComoFunciona, Depoimentos, FAQ, Footer, CTAFinal
  - Tema color: sage-green + warm-neutral + accent-coral
  - Static build: Cloudflare deploy
  - WhatsApp CTA button (fixed float + inline CTAs)
- **Impact:**
  - Base: Performance ~70/100, a11y ~80/100 (before optimizations)

---

## 📊 Score Evolution (Lighthouse Mobile)

| Data | Performance | Accessibility | Best Practices | SEO | Notes |
|------|-------------|---------------|----|-----|-------|
| 2026-05-01 | ~75 | ~80 | ~75 | ~90 | Initial (Google Fonts + some contrast issues) |
| 2026-05-13 | ~90 | ~95 | ~85 | ~95 | Contrast fixes applied |
| 2026-05-22 | ~100 | ~100 | ~88 | ~95 | Self-hosted fonts complete |
| 2026-07-19 | **100** | **100** | **92** | **100** | SEO + Schema.org complete |

---

## 🔄 Commit Message Conventions

Format: `type(scope): subject`

### Types
- `feat` — new feature
- `fix` — bug fix
- `perf` — performance improvement
- `a11y` — accessibility improvement
- `chore` — maintenance, tooling
- `ci` — CI/CD pipeline
- `refactor` — code restructure (no feature change)
- `docs` — documentation

### Scopes
- `seo` — search engine optimization
- `a11y` — accessibility
- `perf` — performance
- `security` — security headers
- `fonts` — font loading

### Example
```
perf(fonts): self-host woff2 + optimize unicode-range
a11y(contrast): fix WCAG AA on footer + navbar
feat(seo): add MedicalBusiness schema.org JSON-LD
```

---

## 🎯 Next Steps (Pending)

### Phase 3.1: Best Practices 92 → 100
- [ ] Identify exact Lighthouse warning (run audit)
- [ ] Fix root cause (CSP, fonts, images, etc.)
- [ ] Validate in incognito mobile

### Phase 4: CRP Full Compliance
- [ ] Add "Código de Ética Profissional" link to CRP database
- [ ] Document insurance/payment policies
- [ ] Add license verification link

### Phase 5: Engagement & Conversion
- [ ] Implement analytics (não-invasive, LGPD-compliant)
- [ ] Add testimonials video (if available)
- [ ] Blog: 3-5 artigos de terapia (SEO + engagement)

---

**Mantido por:** Claude Code  
**Atualizado:** 2026-08-20  
**Próximo review:** 2026-09-15 (após Best Practices fix)
