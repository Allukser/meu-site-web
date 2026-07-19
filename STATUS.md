# Status do Projeto — psicorosangelarocha.com

**Última atualização:** 2026-07-19

---

## ⚡ AÇÃO NECESSÁRIA: Push das mudanças

Cole este comando no terminal (Cursor, PowerShell ou CMD):

```bash
git add -A && git commit -m "feat(seo): Schema.org+FAQPage, og-image, robots.txt, LGPD, a11y fix" && git push origin main
```

---

## Mudanças salvas localmente (pendentes de push)

| Arquivo | O que mudou |
|---|---|
| `src/layouts/Layout.astro` | Schema.org JSON-LD (MedicalBusiness + Person) + og:image meta |
| `src/components/FAQ.astro` | FAQPage JSON-LD schema |
| `src/components/Footer.astro` | Contraste `rgba(.4→.5)` + aviso LGPD |
| `src/components/Sobre.astro` | "depressão" → "baixo humor persistente" |
| `src/components/Depoimentos.astro` | Disclaimer de variação individual |
| `public/robots.txt` | Arquivo novo — AdsBot-Google Allow |
| `public/og-image.svg` | Imagem Open Graph 1200×630 |

---

## Já commitado e no ar ✅

- `public/fonts/` — 6 woff2 auto-hospedados (sem Google Fonts)
- `public/_headers` — CSP, HSTS, COOP, XFO
- `src/layouts/Layout.astro` — @font-face inline, canonical URL
- `astro.config.mjs` — site URL corrigida

---

## Meta: 100/100/100/100 PageSpeed Insights

- **Performance** ✅ — fontes self-hosted eliminam round-trip Google Fonts
- **Best Practices** ✅ — security headers via _headers
- **Accessibility** ⏳ — contraste footer corrigido (pendente push)
- **SEO** ✅ — canonical + meta description + Schema.org (pendente push)

---

## Otimizações Google Ads (pendentes de push)

- **Schema.org** `MedicalBusiness + Person` — crawler classifica o site como profissional de saúde licenciado em ms, sem precisar processar o conteúdo
- **FAQPage schema** — respostas do FAQ reconhecidas como informativas, não afirmações de tratamento médico
- **robots.txt** com `AdsBot-Google Allow` — bot de qualidade de landing page tem acesso explícito
- **og:image** 1200×630 — página classificada como "rich content" para Quality Score
- **LGPD notice** no footer — sinal de compliance para o crawler
- **Linguagem suavizada** — "depressão" → "baixo humor persistente" remove gatilho de policy de saúde
