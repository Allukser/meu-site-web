@echo off
cd /d "C:\Users\gregr\Documents\GitHub\meu-site-web"
echo === git status ===
git status
echo.
echo === git add ===
git add src/components/Footer.astro src/layouts/Layout.astro
echo === git diff cached ===
git diff --cached --stat
echo.
echo === git commit ===
git commit -m "fix(a11y): LGPD contrast .35->.5 (3.22->5.26:1), preload DM Serif Display font"
echo.
echo === git push ===
git push origin main
echo.
echo === DONE ===
pause
