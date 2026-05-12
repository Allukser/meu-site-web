@echo off
setlocal
echo Build e deploy manual para Cloudflare Pages
echo.
echo Recomendado: ligar o repositorio em Cloudflare Pages (build: npm run build, saida: dist).
echo Este script so e necessario para deploy local com Wrangler.
echo.

if "%CLOUDFLARE_API_TOKEN%"=="" (
  echo ERRO: defina a variavel de ambiente CLOUDFLARE_API_TOKEN antes de executar.
  echo Nunca commite tokens no repositorio.
  exit /b 1
)

cd /d "%~dp0"

echo [1/3] Instalando dependencias...
call npm install
if %errorlevel% neq 0 exit /b 1

echo [2/3] Build Astro...
call npm run build
if %errorlevel% neq 0 exit /b 1

echo [3/3] Wrangler pages deploy...
if "%CF_PAGES_PROJECT%"=="" set CF_PAGES_PROJECT=meu-site-web
call npx wrangler pages deploy dist --project-name "%CF_PAGES_PROJECT%" --branch main
if %errorlevel% neq 0 exit /b 1

echo Concluido.
endlocal
