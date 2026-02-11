🌌 Aurora Shell 2.0
A sleek, high-performance terminal theme and diagnostic dashboard for macOS (Zsh) and Windows (PowerShell 7+).

✨ Features

Real-time Diagnostics: View Battery, CPU usage, and Disk space every time you open a terminal.

Session Tracking: Displays a "Start Time" so you know exactly when you began your session.

Cross-Platform: Tailored experiences for both Mac and Windows environments.

Ultra-Clean Prompt: Minimalist cyan-themed prompt showing user@machine.

🚀 Installation
🍎 For macOS (Zsh)

**Option 1: Download Installer (.dmg)**
1. Download [AuroraShell-2.0.0.dmg](https://github.com/YashB-byte/aurora-shell-2/releases/latest)
2. Open the .dmg file
3. Open Terminal and run:
   ```bash
   xattr -d com.apple.quarantine "/Volumes/Aurora Shell 2.0.0 4/AuroraShell.pkg"
   ```
4. Double-click `AuroraShell.pkg` to install
5. Restart your terminal

**Option 2: Command Line Install**
```bash
curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh | bash
```

🪟 For Windows (PowerShell 7+)

> [!IMPORTANT]
> This theme requires Microsoft PowerShell 7.0 or higher. It is not compatible with Microsoft Windows PowerShell 5.1.

**Install PowerShell 7 (if needed):**
```powershell
winget install Microsoft.PowerShell
```

Or for PowerShell Preview:
```powershell
winget install Microsoft.PowerShell.Preview
```

**Run the installer:**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.ps1'))
```

📦 **Dependencies**

macOS requires `lolcat` for colorful output:
```bash
brew install lolcat
```

🛠️ Customization
The main configuration logic is stored in:

Mac: ~/.aurora_theme.sh (sourced in your .zshrc)

Windows: $PROFILE (usually located in Documents\PowerShell\Microsoft.PowerShell_profile.ps1)
