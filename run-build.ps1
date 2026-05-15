Set-Location "C:\Users\gregr\Documents\GitHub\meu-site-web"
$log = "C:\Users\gregr\Documents\GitHub\meu-site-web\build-log.txt"
"=== $(Get-Date) ===" | Out-File $log -Encoding utf8
"[1/2] npm run build" | Add-Content $log
npm run build 2>&1 | Tee-Object -FilePath $log -Append
if ($LASTEXITCODE -ne 0) {
    "ERRO no build! Exit code: $LASTEXITCODE" | Add-Content $log
    exit 1
}
"[2/2] wrangler pages deploy" | Add-Content $log
npx wrangler pages deploy dist --project-name psicologa-roangela-site-astro-cflare --branch main 2>&1 | Tee-Object -FilePath $log -Append
if ($LASTEXITCODE -ne 0) {
    "ERRO no deploy! Exit code: $LASTEXITCODE" | Add-Content $log
    exit 1
}
"=== CONCLUIDO ===" | Add-Content $log
