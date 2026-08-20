@echo off
cd /d "C:\Users\gregr\Documents\GitHub\meu-site-web"
echo === STATUS === > git-check.txt
git status >> git-check.txt 2>&1
echo. >> git-check.txt
echo === LOG === >> git-check.txt
git log --oneline -3 >> git-check.txt 2>&1
echo. >> git-check.txt
echo === DIFF HEAD === >> git-check.txt
git diff HEAD -- src/components/Footer.astro >> git-check.txt 2>&1
echo DONE >> git-check.txt
