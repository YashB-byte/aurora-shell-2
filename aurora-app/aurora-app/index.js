const os = require('os');
const { exec } = require('child_process');

console.log("\x1b[36m%s\x1b[0m", "🌌 AURORA SHELL INSTALLER");
console.log("----------------------------");

const platform = os.platform();

if (platform === 'darwin') {
    console.log("🍎 Mac detected. Launching Zsh Installer...");
    exec('curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh | bash', (err, stdout, stderr) => {
        if (err) { console.error("❌ Error:", err); return; }
        console.log(stdout);
        console.log("✅ Installation Complete! Restart your terminal.");
    });
} else if (platform === 'win32') {
    console.log("🪟 Windows detected. Launching PowerShell Installer...");
    const psCommand = 'Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString(\'https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.ps1\'))';
    exec(`powershell -Command "${psCommand}"`, (err, stdout, stderr) => {
        if (err) { console.error("❌ Error:", err); return; }
        console.log(stdout);
        console.log("✅ Installation Complete!");
    });
} else {
    console.log("🐧 Linux or other OS detected. Custom logic needed.");
}
