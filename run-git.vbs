Dim shell, result
Set shell = CreateObject("WScript.Shell")
shell.CurrentDirectory = "C:\Users\gregr\Documents\GitHub\meu-site-web"

' Run git commands and capture output
Dim cmd
cmd = "cmd /c """ & _
      "cd /d C:\Users\gregr\Documents\GitHub\meu-site-web && " & _
      "git status > git-status.txt 2>&1 && " & _
      "git log --oneline -5 >> git-status.txt 2>&1 && " & _
      "git add src/components/Footer.astro src/layouts/Layout.astro >> git-status.txt 2>&1 && " & _
      "git diff --cached --name-only >> git-status.txt 2>&1 && " & _
      "echo --- >> git-status.txt && " & _
      "git commit -m " & Chr(34) & "fix(a11y): LGPD contrast .35-.5 (3.22-5.26:1), preload DM Serif Display font" & Chr(34) & " >> git-status.txt 2>&1 && " & _
      "git push origin main >> git-status.txt 2>&1 && " & _
      "echo DONE >> git-status.txt" & _
      """"

result = shell.Run(cmd, 0, True)

MsgBox "Git push finalizado! Verifique git-status.txt para detalhes. Código: " & result
