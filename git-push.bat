@echo off
cd /d "C:\Users\gregr\Documents\GitHub\meu-site-web"
git status > git-status.txt 2>&1
git log --oneline -8 >> git-status.txt 2>&1
git add src/components/Footer.astro src/layouts/Layout.astro >> git-status.txt 2>&1
git diff --cached --stat >> git-status.txt 2>&1
echo --- >> git-status.txt
git commit -m "fix(a11y): LGPD contrast .35->5 (3.22->5.26:1), preload DM Serif Display font" >> git-status.txt 2>&1
git push origin main >> git-status.txt 2>&1
echo DONE >> git-status.txt
