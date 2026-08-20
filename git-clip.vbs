Set oShell = CreateObject("WScript.Shell")
Dim sRepo
sRepo = "C:\Users\gregr\Documents\GitHub\meu-site-web"

Function RunCmd(cmd)
    Dim oE, r
    Set oE = oShell.Exec(cmd)
    oE.StdIn.Close
    r = ""
    Do While Not oE.StdOut.AtEndOfStream
        r = r & oE.StdOut.ReadLine() & vbCrLf
    Loop
    Do While Not oE.StdErr.AtEndOfStream
        r = r & oE.StdErr.ReadLine() & vbCrLf
    Loop
    If Len(Trim(r)) = 0 Then r = "(no output)"
    RunCmd = r
End Function

Dim sAll
sAll = "[STATUS]" & vbCrLf & RunCmd("git -C """ & sRepo & """ status --short") & vbCrLf
sAll = sAll & "[ADD]" & vbCrLf & RunCmd("git -C """ & sRepo & """ add src/components/Footer.astro src/layouts/Layout.astro") & vbCrLf
sAll = sAll & "[STATUS2]" & vbCrLf & RunCmd("git -C """ & sRepo & """ status --short") & vbCrLf
sAll = sAll & "[COMMIT]" & vbCrLf & RunCmd("git -C """ & sRepo & """ commit -m ""fix(a11y): LGPD contrast .35->.5, preload DM Serif Display font""") & vbCrLf
sAll = sAll & "[PUSH]" & vbCrLf & RunCmd("git -C """ & sRepo & """ push origin main") & vbCrLf
sAll = sAll & "[LOG]" & vbCrLf & RunCmd("git -C """ & sRepo & """ log --oneline -2")

' Write result to clipboard via clip.exe
Dim oClip
Set oClip = oShell.Exec("clip")
oClip.StdIn.Write sAll
oClip.StdIn.Close
