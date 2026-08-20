Set-Location 'C:\Users\gregr\Documents\GitHub\meu-site-web'
$out = @()
$out += "=== PWD ==="
$out += (Get-Location).Path
$out += "=== GIT STATUS ==="
$out += (git status 2>&1)
$out += "=== GIT ADD ==="
$out += (git add src/components/Footer.astro src/layouts/Layout.astro 2>&1)
$out += "=== GIT DIFF CACHED ==="
$out += (git diff --cached --stat 2>&1)
$out += "=== GIT COMMIT ==="
$out += (git commit -m "fix(a11y): LGPD contrast .35->.5 (3.22->5.26:1), preload DM Serif Display font" 2>&1)
$out += "=== GIT PUSH ==="
$out += (git push origin main 2>&1)
$out += "=== DONE ==="
$out | Out-File -FilePath 'C:\Users\gregr\Documents\GitHub\meu-site-web\ps-result.txt' -Encoding UTF8
