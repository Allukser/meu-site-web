@echo off
cd /d "C:\Users\gregr\Documents\GitHub\meu-site-web"
git add src/components/Footer.astro src/layouts/Layout.astro
git commit -m "fix(a11y): LGPD contrast .35->.5 (3.22->5.26:1), preload DM Serif Display font"
echo %ERRORLEVEL% > "C:\Users\gregr\Documents\GitHub\meu-site-web\commit-exit.txt"
git log --oneline -1 >> "C:\Users\gregr\Documents\GitHub\meu-site-web\commit-exit.txt"
