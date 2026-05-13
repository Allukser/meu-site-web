/**
 * Google Apps Script — Dashboard de GCLIDs / Leads
 *
 * SETUP:
 * 1. Acesse script.google.com → Novo projeto
 * 2. Cole este código
 * 3. Execute setupSheet() UMA vez para criar os cabeçalhos
 * 4. Implante como Web App:
 *    - Execute como: Eu mesmo
 *    - Quem pode acessar: Qualquer pessoa
 * 5. Copie a URL do Web App e cole em worker/wrangler.toml → APPS_SCRIPT_URL
 *
 * PLANILHA: UUID | GCLID | Capturado | Clicado | Página | Fonte | Evento | Nome | Telefone | Status | Valor
 */

var SHEET_NAME = 'Leads';

/* ── Recebe dados do Cloudflare Worker ─────────────────────────────── */
function doPost(e) {
  try {
    var data   = JSON.parse(e.postData.contents);
    var sheet  = getOrCreateSheet();
    var now    = new Date();

    sheet.appendRow([
      data.uuid         || '',
      data.gclid        || '',
      data.captured_at  ? new Date(data.captured_at) : now,
      data.clicked_at   ? new Date(data.clicked_at)  : now,
      now,                                  // received_at (servidor)
      data.landing_page || '/',
      data.source       || 'unknown',
      data.event_type   || 'wa_click',
      '',                                   // nome (preencher manualmente)
      '',                                   // telefone (preencher manualmente)
      'lead',                               // status inicial
      '',                                   // valor da conversão
    ]);

    return ContentService
      .createTextOutput(JSON.stringify({ ok: true }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (err) {
    return ContentService
      .createTextOutput(JSON.stringify({ error: err.message }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

/* ── Cria cabeçalhos na primeira execução ───────────────────────────── */
function setupSheet() {
  var sheet = getOrCreateSheet();
  var headers = [
    'UUID', 'GCLID', 'Capturado em', 'Clicou WA em', 'Recebido em',
    'Página', 'Fonte', 'Evento',
    'Nome', 'Telefone', 'Status', 'Valor (R$)'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  // Formata cabeçalho
  var headerRange = sheet.getRange(1, 1, 1, headers.length);
  headerRange.setBackground('#3d6b57');
  headerRange.setFontColor('#ffffff');
  headerRange.setFontWeight('bold');

  // Congela linha de cabeçalho
  sheet.setFrozenRows(1);

  // Largura das colunas
  sheet.setColumnWidth(1, 280);  // UUID
  sheet.setColumnWidth(2, 220);  // GCLID
  sheet.setColumnWidth(3, 160);  // Capturado em
  sheet.setColumnWidth(4, 160);  // Clicou WA em
  sheet.setColumnWidth(5, 160);  // Recebido em
  sheet.setColumnWidth(8, 100);  // Evento
  sheet.setColumnWidth(11, 120); // Status

  SpreadsheetApp.getActiveSpreadsheet().toast('Planilha configurada!', 'Setup concluído', 5);
}

/* ── Validação de status (dropdown) ────────────────────────────────── */
function addStatusValidation() {
  var sheet = getOrCreateSheet();
  var rule  = SpreadsheetApp.newDataValidation()
    .requireValueInList(['lead', 'agendado', 'convertido', 'perdido'], true)
    .build();
  // Aplica nas primeiras 1000 linhas da coluna Status (K)
  sheet.getRange('K2:K1000').setDataValidation(rule);
}

/* ── Helper interno ─────────────────────────────────────────────────── */
function getOrCreateSheet() {
  var ss    = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(SHEET_NAME);
  if (!sheet) {
    sheet = ss.insertSheet(SHEET_NAME);
  }
  return sheet;
}

/* ── Health check (GET) ─────────────────────────────────────────────── */
function doGet() {
  return ContentService
    .createTextOutput(JSON.stringify({ ok: true, sheet: SHEET_NAME }))
    .setMimeType(ContentService.MimeType.JSON);
}
