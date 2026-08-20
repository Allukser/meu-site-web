Set oShell = CreateObject("WScript.Shell")
Set oFSO = CreateObject("Scripting.FileSystemObject")

Dim sRepo
sRepo = "C:\Users\gregr\Documents\GitHub\meu-site-web"

Dim sOut
sOut = ""

' Run git add
Dim oExec
Set oExec = oShell.Exec("git -C """ & sRepo & """ add src/components/Footer.astro src/layouts/Layout.astro")
oExec.StdIn.Close
Do While Not oExec.StdOut.AtEndOfStream
    sOut = sOut & oExec.StdOut.ReadLine() & vbCrLf
Loop
Do While Not oExec.StdErr.AtEndOfStream
    sOut = sOut & "ERR: " & oExec.StdErr.ReadLine() & vbCrLf
Loop
sOut = "=ADD=" & vbCrLf & sOut

' Run git commit
Set oExec = oShell.Exec("git -C """ & sRepo & """ commit -m ""fix(a11y): LGPD contrast .35->.5, preload DM Serif Display font""")
oExec.StdIn.Close
Dim sCommit
sCommit = ""
Do While Not oExec.StdOut.AtEndOfStream
    sCommit = sCommit & oExec.StdOut.ReadLine() & vbCrLf
Loop
Do While Not oExec.StdErr.AtEndOfStream
    sCommit = sCommit & "ERR: " & oExec.StdErr.ReadLine() & vbCrLf
Loop
sOut = sOut & "=COMMIT=" & vbCrLf & sCommit

' Run git push
Set oExec = oShell.Exec("git -C """ & sRepo & """ push origin main")
oExec.StdIn.Close
Dim sPush
sPush = ""
Do While Not oExec.StdOut.AtEndOfStream
    sPush = sPush & oExec.StdOut.ReadLine() & vbCrLf
Loop
Do While Not oExec.StdErr.AtEndOfStream
    sPush = sPush & oExec.StdErr.ReadLine() & vbCrLf
Loop
sOut = sOut & "=PUSH=" & vbCrLf & sPush

' Run git log
Set oExec = oShell.Exec("git -C """ & sRepo & """ log --oneline -2")
oExec.StdIn.Close
Dim sLog
sLog = ""
Do While Not oExec.StdOut.AtEndOfStream
    sLog = sLog & oExec.StdOut.ReadLine() & vbCrLf
Loop
sOut = sOut & "=LOG=" & vbCrLf & sLog & "=DONE="

' Write result using FSO
Dim sResultPath
sResultPath = sRepo & "\.git\vbs-result.txt"

Dim oFile
Set oFile = oFSO.CreateTextFile(sResultPath, True)
oFile.Write sOut
oFile.Close

MsgBox "Done! Check .git\vbs-result.txt"
