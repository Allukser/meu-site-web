# deploy-worker.ps1
# Script automático para criar KV namespace e fazer deploy do Cloudflare Worker
# Execute com: clique direito → "Executar com PowerShell"

$ErrorActionPreference = "Stop"
$workerDir = "C:\Users\gregr\Documents\GitHub\meu-site-web\worker"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  DEPLOY CLOUDFLARE WORKER - ROANGELA" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se estamos no diretório correto
if (-not (Test-Path $workerDir)) {
    Write-Host "ERRO: Diretório do worker não encontrado: $workerDir" -ForegroundColor Red
    Pause
    exit 1
}

Set-Location $workerDir
Write-Host "Diretório: $workerDir" -ForegroundColor Gray
Write-Host ""

# Verificar se wrangler está disponível
Write-Host "[1/3] Verificando wrangler..." -ForegroundColor Yellow
try {
    $wranglerVersion = npx wrangler --version 2>&1 | Select-Object -First 1
    Write-Host "      OK: $wranglerVersion" -ForegroundColor Green
} catch {
    Write-Host "      wrangler não encontrado, instalando..." -ForegroundColor Yellow
    npm install -g wrangler
}

Write-Host ""

# Verificar se o KV namespace já existe no wrangler.toml
$tomlContent = Get-Content "wrangler.toml" -Raw
if ($tomlContent -notmatch 'SUBSTITUA_PELO_ID_DO_KV_NAMESPACE') {
    Write-Host "[2/3] KV namespace já configurado no wrangler.toml" -ForegroundColor Green
} else {
    # Criar KV namespace
    Write-Host "[2/3] Criando KV namespace GCLID_KV..." -ForegroundColor Yellow
    Write-Host "      (pode abrir o navegador para autenticação Cloudflare)" -ForegroundColor Gray
    Write-Host ""

    $kvOutput = npx wrangler kv namespace create "GCLID_KV" 2>&1
    Write-Host $kvOutput

    # Extrair o ID do output
    $idMatch = ($kvOutput | Out-String) | Select-String -Pattern 'id\s*=\s*"([a-f0-9]{32})"'

    if ($idMatch -and $idMatch.Matches.Groups[1].Value) {
        $kvId = $idMatch.Matches.Groups[1].Value
        Write-Host ""
        Write-Host "      KV Namespace ID: $kvId" -ForegroundColor Green

        # Atualizar wrangler.toml
        $newToml = $tomlContent -replace 'SUBSTITUA_PELO_ID_DO_KV_NAMESPACE', $kvId
        $newToml | Set-Content "wrangler.toml" -NoNewline
        Write-Host "      wrangler.toml atualizado!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "AVISO: Não foi possível extrair o ID automaticamente." -ForegroundColor Yellow
        Write-Host "Copie o 'id' mostrado acima e cole aqui:" -ForegroundColor Yellow
        $kvId = Read-Host "  KV namespace id"

        if ($kvId) {
            $newToml = $tomlContent -replace 'SUBSTITUA_PELO_ID_DO_KV_NAMESPACE', $kvId
            $newToml | Set-Content "wrangler.toml" -NoNewline
            Write-Host "      wrangler.toml atualizado!" -ForegroundColor Green
        } else {
            Write-Host "ERRO: ID não informado. Abortando." -ForegroundColor Red
            Pause
            exit 1
        }
    }
}

Write-Host ""

# Deploy
Write-Host "[3/3] Fazendo deploy do Worker..." -ForegroundColor Yellow
Write-Host ""
npx wrangler deploy

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  DEPLOY CONCLUÍDO!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "A URL do Worker é:" -ForegroundColor Cyan
Write-Host "  https://roangela-gclid.YOUR-ACCOUNT.workers.dev/lead" -ForegroundColor White
Write-Host ""
Write-Host "Copie a URL exibida acima e informe ao Claude para" -ForegroundColor Gray
Write-Host "atualizar o arquivo Layout.astro." -ForegroundColor Gray
Write-Host ""
Pause
