@echo off
cd /d "C:\Users\gregr\Documents\GitHub\meu-site-web"
set OUT=C:\Users\gregr\AppData\Local\Temp\git-push-result.txt
echo === START === > %OUT%
echo %date% %time% >> %OUT%
git add src/components/Footer.astro src/layouts/Layout.astro >> %OUT% 2>&1
echo === AFTER ADD === >> %OUT%
git commit -m "fix(a11y): LGPD contrast .35->.5 (3.22->5.26:1), preload DM Serif Display font" >> %OUT% 2>&1
echo === AFTER COMMIT === >> %OUT%
git push origin main >> %OUT% 2>&1
echo === DONE === >> %OUT%
git log --oneline -1 >> %OUT% 2>&1
