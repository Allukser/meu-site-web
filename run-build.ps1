Set-Location "C:\dev"
$log = "C:\dev\build-log.txt"
"=== $(Get-Date) ===" | Out-File $log -Encoding utf8

# --- 1. Build Astro ---
"[1/3] npm run build" | Add-Content $log
npm run build 2>&1 | Tee-Object -FilePath $log -Append
if ($LASTEXITCODE -ne 0) {
    "ERRO no build! Exit code: $LASTEXITCODE" | Add-Content $log
    exit 1
}

# --- 2. Deploy site principal (meu-site-web) com Custom Domain ---
"[2/3] wrangler deploy (meu-site-web)" | Add-Content $log
npx wrangler deploy 2>&1 | Tee-Object -FilePath $log -Append
if ($LASTEXITCODE -ne 0) {
    "ERRO no deploy do site! Exit code: $LASTEXITCODE" | Add-Content $log
    exit 1
}

# --- 3. Deploy worker GCLID (roangela-gclid) ---
"[3/3] wrangler deploy (roangela-gclid)" | Add-Content $log
Set-Location "C:\Users\gregr\Documents\GitHub\meu-site-web\worker"
npx wrangler deploy --config wrangler.toml 2>&1 | Tee-Object -FilePath $log -Append
if ($LASTEXITCODE -ne 0) {
    "ERRO no deploy do worker GCLID! Exit code: $LASTEXITCODE" | Add-Content $log
    exit 1
}

"=== CONCLUIDO ===" | Add-Content $log
