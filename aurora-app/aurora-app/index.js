const { exec } = require('child_process');

console.log("🌌 Aurora Shell 2.0 - Starting Windows Installation...");

// This command pulls your logic from the GitHub repo you just updated
const psCommand = `PowerShell -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/build-installer.ps1'))"`;

exec(psCommand, (error, stdout, stderr) => {
    if (error) {
        console.error(`❌ Installation Error: ${error.message}`);
        return;
    }
    if (stderr) {
        console.error(`⚠️ Warning: ${stderr}`);
    }
    console.log(`✅ Success:\n${stdout}`);
    console.log("\nInstallation finished. You can now close this window and restart PowerShell.");
});