---
name: astro-cloudflare-git
description: >-
  Define boas práticas para sites e apps Astro com Git e Cloudflare (Pages ou
  Workers, Wrangler, build CI). Usar ao criar ou estruturar projetos Astro, ao
  configurar deploy na Cloudflare, ao interpretar logs de build, ou quando o
  utilizador mencionar Astro com Git, Cloudflare, wrangler ou bun install no CI.
---

# Astro + Git + Cloudflare — boas práticas

## Quando ler esta skill

- Novo site ou app em Astro pensado para produção.
- Ligação do repositório a Cloudflare (Pages com Git ou pipeline com `wrangler deploy`).
- Erros de build/deploy na Cloudflare (Node, Wrangler, pastas em falta, 0 páginas).

## Estrutura do projeto Astro

- Usar layout habitual: `src/pages/` (rotas), `src/components/`, `src/layouts/`, `src/styles/` ou CSS por componente.
- Manter `public/` só para ficheiros estáticos servidos na raiz (favicons, `.well-known`, etc.).
- Em `astro.config.mjs`, para sites estáticos: `output: 'static'` e `site: 'https://dominio.tld'` quando houver URL definitiva (canonical/OG).
- Só adicionar `@astrojs/cloudflare` quando existir **render no servidor** ou requisitos de Workers (bindings, SSR). Sites 100% estáticos em Cloudflare **Pages** não precisam do adapter.

## Git

- Incluir `.gitignore` com pelo menos: `node_modules/`, `dist/`, `.astro/`, `.env`, `.env.*`, logs e ficheiros do SO (`.DS_Store`, `Thumbs.db`).
- **Nunca** commitar tokens de API, `CF_API_TOKEN`, passwords ou `deploy-*.bat` com credenciais. Preferir variáveis de ambiente no CI ou segredos do painel Cloudflare.
- Mensagens de commit em frases completas e descritivas; PRs pequenos e focados.
- Garantir que tudo o que o build precisa (`src/pages`, `public/`, configs) está no remoto antes de depender do CI.

## Cloudflare — Pages (Git integrado)

- **Build command:** `npm run build` (ou `bun run build` se o lockfile e scripts forem coerentes).
- **Output directory:** `dist`.
- **Root directory:** raiz do `package.json`, salvo monorepo — aí apontar para a subpasta correta.
- Para site estático puro, **deixar o “Deploy command” vazio** quando o produto for só Pages a servir `dist` (o upload é automático após o build).
- Se existir passo extra, documentar no README do projeto (não duplicar aqui).

## Cloudflare — Workers + `wrangler deploy`

- Ter `wrangler.jsonc` (ou `wrangler.toml`) **no repositório** para evitar assistentes interativos (`astro add cloudflare`) no CI.
- Site **estático** servido por Worker com assets: configurar `assets.directory` para `./dist` e evitar fluxos que exijam `main`/`_worker.js` se não houver código Worker.
- **Versão do Node vs Wrangler:** Wrangler **≥ 4.87** exige Node **≥ 22**. Se o ambiente Cloudflare fixar Node 20, fixar Wrangler numa versão **anterior a 4.87** (por exemplo `4.86.0` exato em `devDependencies`) **ou** subir o runtime para Node 22 no painel/variáveis.
- Preferir `wrangler` em `devDependencies` com versão **fixa** ou intervalo que não suba acidentalmente para uma major/minor incompatível.
- Se o Wrangler ou o adapter Astro referenciar `public/.assetsignore`, o ficheiro deve existir (pode ser só comentários).

## Scripts de verificação pós-build

- Opcional mas útil: após `astro build`, um script que verifique `dist/index.html` e a existência de `src/pages`, falhando com mensagem clara no CI (evita deploy de `dist` vazio).

## Lockfile e gestor de pacotes

- Se o CI usar **Bun** (`bun install`), commitar **`bun.lockb`** estável ou alinhar documentação para um único gestor (Bun vs npm), para builds reprodutíveis.
- Evitar `^` em ferramentas sensíveis à versão do Node (Wrangler) quando o CI estiver preso a Node 20.

## Segurança e domínio

- Não expor segredos em repositórios públicos; rotação de tokens se algo tiver sido commitado por engano.
- HTTPS e domínio customizado configurados no painel após o primeiro deploy bem-sucedido.

## Checklist rápido antes do primeiro deploy

- [ ] `npm run build` ou `bun run build` passa localmente.
- [ ] Existe pelo menos uma rota em `src/pages/` e `dist/index.html` é gerado.
- [ ] `.gitignore` adequado; sem credenciais no repo.
- [ ] Versão de Node no CI compatível com Wrangler (ou Wrangler pinado).
- [ ] Cloudflare: build output `dist`, root correto, comandos de deploy alinhados com Pages vs Workers.

## Referência cruzada

- Para detalhes do formato de skills do Cursor (nome, `description`, tamanho), ver a documentação interna de criação de skills; esta pasta segue o layout `skill-name/SKILL.md`.
