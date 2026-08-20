@echo off
cd /d "C:\Users\gregr\Documents\GitHub\meu-site-web"
echo START > .git\run-result.txt
date /t >> .git\run-result.txt
git add src/components/Footer.astro src/layouts/Layout.astro >> .git\run-result.txt 2>&1
echo AFTER_ADD >> .git\run-result.txt
git commit -m "fix(a11y): LGPD contrast .35->.5, preload DM Serif Display font" >> .git\run-result.txt 2>&1
echo AFTER_COMMIT >> .git\run-result.txt
git push origin main >> .git\run-result.txt 2>&1
echo AFTER_PUSH >> .git\run-result.txt
git log --oneline -2 >> .git\run-result.txt 2>&1
echo DONE >> .git\run-result.txt
