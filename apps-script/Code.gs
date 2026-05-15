/**
 * Google Apps Script — Backend + Dashboard de GCLIDs / Leads
 *
 * SETUP:
 * 1. Acesse script.google.com → Novo projeto
 * 2. Cole este código (Code.gs) e o arquivo Dashboard.html
 * 3. Execute setupSheet() UMA vez para criar os cabeçalhos
 * 4. Implante como Web App:
 *    - Execute como: Eu mesmo
 *    - Quem pode acessar: Qualquer pessoa com o link (ou só você)
 * 5. Copie a URL do Web App e cole em worker/wrangler.toml → APPS_SCRIPT_URL
 *
 * WEB APP URL (atual):
 * https://script.google.com/macros/s/AKfycbxX46q6VVJVFcGwUbZ6K6DPPZ2368qaO1d5_8tp4VyX1vJEei5Md61Ul36QIyLx1Rlq/exec
 *
 * ROTAS:
 *   GET  /exec              → abre o Dashboard HTML
 *   GET  /exec?action=data  → retorna leads como JSON (para o dashboard)
 *   POST /exec              → recebe lead do Worker OU atualiza registro
 */

var SPREADSHEET_ID = '1T1MmUezL7wJcwk14ecd0UuJtCJoM-i5qheVgTPtMYTk';
var SHEET_NAME   = 'Leads';
var CONV_NAME    = 'Consulta Confirmada'; // nome da conversão no Google Ads
var CONV_CURRENCY = 'BRL';

/* ═══════════════════════════════════════════════════════════════════
   ROTAS GET
   ═══════════════════════════════════════════════════════════════════ */

function doGet(e) {
  var action = e && e.parameter ? e.parameter.action : null;

  if (action === 'data') {
    return jsonResponse(getLeadsData());
  }
  if (action === 'export_ads') {
    return exportGoogleAds();
  }

  // Servir o dashboard HTML
  return HtmlService.createTemplateFromFile('Dashboard')
    .evaluate()
    .setTitle('Dashboard · Leads Roangela Rocha')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

/* ═══════════════════════════════════════════════════════════════════
   ROTAS POST
   ═══════════════════════════════════════════════════════════════════ */

function doPost(e) {
  try {
    var body = JSON.parse(e.postData.contents);

    // Atualização de lead vinda do dashboard
    if (body._action === 'update') {
      return jsonResponse(updateLeadData(body));
    }
    // Novo lead vindo do Worker
    return jsonResponse(insertLead(body));

  } catch (err) {
    return jsonResponse({ error: err.message }, 500);
  }
}

/* ═══════════════════════════════════════════════════════════════════
   FUNÇÕES CHAMÁVEIS PELO DASHBOARD (google.script.run)
   ═══════════════════════════════════════════════════════════════════ */

function getLeadsData() {
  var sheet = getOrCreateSheet();
  var data  = sheet.getDataRange().getValues();
  if (data.length < 2) return { leads: [], stats: calcStats([]) };

  var headers = data[0];
  var leads   = data.slice(1).map(function (row) {
    var obj = {};
    headers.forEach(function (h, i) {
      var v = row[i];
      obj[h] = (v instanceof Date) ? v.toISOString() : v;
    });
    return obj;
  }).filter(function (r) { return r['UUID']; });

  return { leads: leads, stats: calcStats(leads) };
}

function updateLeadData(params) {
  var sheet   = getOrCreateSheet();
  var data    = sheet.getDataRange().getValues();
  var headers = data[0];
  var uuidCol = headers.indexOf('UUID');

  for (var i = 1; i < data.length; i++) {
    if (data[i][uuidCol] === params.uuid) {
      var updates = ['Nome', 'Telefone', 'Status', 'Valor (R$)', 'Convertido em'];
      updates.forEach(function (key) {
        if (params[key] !== undefined) {
          var col = headers.indexOf(key);
          if (col >= 0) {
            var val = params[key];
            // Converter string de data para objeto Date
            if (key === 'Convertido em' && val) {
              val = new Date(val);
            }
            sheet.getRange(i + 1, col + 1).setValue(val);
          }
        }
      });
      return { ok: true };
    }
  }
  return { error: 'lead não encontrado' };
}

/* ═══════════════════════════════════════════════════════════════════
   INSERT LEAD (recebido do Worker)
   ═══════════════════════════════════════════════════════════════════ */

function insertLead(data) {
  var sheet = getOrCreateSheet();
  var now   = new Date();

  sheet.appendRow([
    data.uuid         || '',
    data.gclid        || '',
    data.captured_at  ? new Date(data.captured_at) : now,
    data.clicked_at   ? new Date(data.clicked_at)  : now,
    now,
    data.landing_page || '/',
    data.source       || 'unknown',
    data.event_type   || 'wa_click',
    '',   // Nome
    '',   // Telefone
    'lead',
    '',   // Valor
    '',   // Convertido em
  ]);

  return { ok: true };
}

/* ═══════════════════════════════════════════════════════════════════
   EXPORT GOOGLE ADS OCT (CSV)
   ═══════════════════════════════════════════════════════════════════ */

function exportGoogleAds() {
  var result = getLeadsData();
  var rows   = result.leads.filter(function (l) {
    return l['Status'] === 'convertido' && l['GCLID'] && l['Convertido em'];
  });

  var lines = ['Google Click ID,Conversion Name,Conversion Time,Conversion Value,Conversion Currency'];
  rows.forEach(function (r) {
    var ts = new Date(r['Convertido em']);
    var formatted = Utilities.formatDate(ts, Session.getScriptTimeZone(), 'yyyy-MM-dd HH:mm:ss');
    lines.push([
      r['GCLID'],
      CONV_NAME,
      formatted,
      r['Valor (R$)'] || '',
      CONV_CURRENCY
    ].join(','));
  });

  return ContentService
    .createTextOutput(lines.join('\n'))
    .setMimeType(ContentService.MimeType.CSV);
}

/* ═══════════════════════════════════════════════════════════════════
   HELPERS
   ═══════════════════════════════════════════════════════════════════ */

function calcStats(leads) {
  var total      = leads.length;
  var agendados  = leads.filter(function (l) { return l['Status'] === 'agendado'; }).length;
  var convertidos= leads.filter(function (l) { return l['Status'] === 'convertido'; }).length;
  var perdidos   = leads.filter(function (l) { return l['Status'] === 'perdido'; }).length;
  var receita    = leads.reduce(function (sum, l) {
    return sum + (parseFloat(l['Valor (R$)']) || 0);
  }, 0);
  var taxa = total > 0 ? Math.round((convertidos / total) * 100) : 0;
  return { total: total, agendados: agendados, convertidos: convertidos,
           perdidos: perdidos, receita: receita, taxa: taxa };
}

function getOrCreateSheet() {
  var ss    = SpreadsheetApp.openById(SPREADSHEET_ID);
  var sheet = ss.getSheetByName(SHEET_NAME);
  if (!sheet) { sheet = ss.insertSheet(SHEET_NAME); }
  return sheet;
}

function jsonResponse(obj, status) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

/* ═══════════════════════════════════════════════════════════════════
   SETUP INICIAL (rodar uma vez)
   ═══════════════════════════════════════════════════════════════════ */

function setupSheet() {
  var sheet   = getOrCreateSheet();
  var headers = [
    'UUID', 'GCLID', 'Capturado em', 'Clicou WA em', 'Recebido em',
    'Página', 'Fonte', 'Evento',
    'Nome', 'Telefone', 'Status', 'Valor (R$)', 'Convertido em'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  var hRange = sheet.getRange(1, 1, 1, headers.length);
  hRange.setBackground('#3d6b57').setFontColor('#fff').setFontWeight('bold');
  sheet.setFrozenRows(1);
  sheet.setColumnWidths(1, headers.length, 150);
  sheet.setColumnWidth(1, 280);
  sheet.setColumnWidth(2, 220);

  // Dropdown de status
  var rule = SpreadsheetApp.newDataValidation()
    .requireValueInList(['lead','agendado','convertido','perdido'], true).build();
  sheet.getRange('K2:K1000').setDataValidation(rule);

  SpreadsheetApp.getActiveSpreadsheet().toast('Planilha configurada!', 'Setup', 5);
}
