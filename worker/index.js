/**
 * Cloudflare Worker — Receptor de GCLIDs
 * Recebe eventos do frontend (page_view e wa_click),
 * persiste no KV e replica para o Google Sheets via Apps Script.
 *
 * Deploy: cd worker && npx wrangler deploy
 */

export default {
  async fetch(request, env, ctx) {
    const url    = new URL(request.url);
    const origin = request.headers.get('Origin') || '';

    // ── CORS preflight ───────────────────────────────────────────────
    if (request.method === 'OPTIONS') {
      return corsOk(null, 204, origin, env);
    }

    // ── Roteamento ───────────────────────────────────────────────────
    if (request.method === 'POST' && url.pathname === '/lead') {
      return handleLead(request, env, ctx, origin);
    }

    // Health-check (útil para testar o Worker manualmente)
    if (request.method === 'GET' && url.pathname === '/ping') {
      return corsOk(JSON.stringify({ ok: true }), 200, origin, env);
    }

    return corsOk(JSON.stringify({ error: 'not_found' }), 404, origin, env);
  },
};

/* ── Handler principal ──────────────────────────────────────────────── */
async function handleLead(request, env, ctx, origin) {
  let body;
  try {
    body = await request.json();
  } catch {
    return corsOk(JSON.stringify({ error: 'invalid_json' }), 400, origin, env);
  }

  if (!body.gclid || typeof body.gclid !== 'string') {
    return corsOk(JSON.stringify({ error: 'missing_gclid' }), 400, origin, env);
  }

  const uuid = crypto.randomUUID();
  const now  = Date.now();

  const record = {
    uuid,
    gclid:        body.gclid.trim(),
    captured_at:  Number(body.captured_at) || now,
    clicked_at:   Number(body.clicked_at)  || now,
    received_at:  now,
    landing_page: body.landing_page || '/',
    source:       body.source       || 'unknown',
    event_type:   body.event_type   || 'wa_click',
    // Campos preenchidos manualmente depois na planilha
    nome:         '',
    telefone:     '',
    status:       'lead',           // lead → agendado → convertido
    valor:        '',
  };

  // ── Persiste no KV (90 dias) ─────────────────────────────────────
  await env.GCLID_KV.put(
    `lead:${uuid}`,
    JSON.stringify(record),
    { expirationTtl: 90 * 24 * 60 * 60 }
  );

  // ── Replica para Google Sheets via Apps Script (fire-and-forget) ──
  if (env.APPS_SCRIPT_URL && !env.APPS_SCRIPT_URL.startsWith('SUBSTITUA')) {
    ctx.waitUntil(
      fetch(env.APPS_SCRIPT_URL, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(record),
      }).catch(() => { /* falha silenciosa — KV já salvou */ })
    );
  }

  return corsOk(JSON.stringify({ ok: true, uuid }), 200, origin, env);
}

/* ── CORS helper ────────────────────────────────────────────────────── */
function corsOk(body, status, origin, env) {
  // Permite o domínio prod + qualquer subdomínio pages.dev em testes
  const allowed = env.ALLOWED_ORIGIN || '';
  const isAllowed =
    origin === allowed ||
    origin.endsWith('.pages.dev') ||
    origin === '';           // chamadas diretas (ex: wrangler tail / curl)

  return new Response(body, {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin':  isAllowed ? origin || '*' : allowed,
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}
