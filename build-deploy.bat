@echo off
setlocal
set LOG=%~dp0build-log.txt
echo === %date% %time% === > "%LOG%"
echo === Build e Deploy Cloudflare Pages ===
echo === Build e Deploy Cloudflare Pages === >> "%LOG%"
cd /d "%~dp0"

echo Verificando node e npm... >> "%LOG%"
where node >> "%LOG%" 2>&1
where npm  >> "%LOG%" 2>&1
node --version >> "%LOG%" 2>&1
npm  --version >> "%LOG%" 2>&1

echo [1/3] npm install... >> "%LOG%"
echo [1/3] Instalando dependencias (npm install)...
call npm install >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
  echo ERRO no npm install! Veja build-log.txt >> "%LOG%"
  echo ERRO no npm install! Veja build-log.txt
  pause
  exit /b 1
)

echo [2/3] npm run build... >> "%LOG%"
echo [2/3] Build Astro...
call npm run build >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
  echo ERRO no build! Veja build-log.txt >> "%LOG%"
  echo ERRO no build! Veja build-log.txt
  pause
  exit /b 1
)

echo [3/3] wrangler pages deploy... >> "%LOG%"
echo [3/3] Deploy para Cloudflare Pages...
call npx wrangler pages deploy dist --project-name psicologa-roangela-site-astro-cflare --branch main >> "%LOG%" 2>&1
if %errorlevel% neq 0 (
  echo ERRO no deploy! Veja build-log.txt >> "%LOG%"
  echo ERRO no deploy! Veja build-log.txt
  pause
  exit /b 1
)

echo === CONCLUIDO! === >> "%LOG%"
echo === Concluido! ===
pause
endlocal
