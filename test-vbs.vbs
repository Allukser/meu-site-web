Set fso = CreateObject("Scripting.FileSystemObject")
Set ts = fso.OpenTextFile("C:\Users\gregr\Documents\GitHub\meu-site-web\vbs-ok.txt", 2, True)
ts.Write "VBS ran at " & Now()
ts.Close
MsgBox "VBS OK!"
