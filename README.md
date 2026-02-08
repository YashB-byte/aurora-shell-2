🌌 Aurora Shell 2.0
A sleek, high-performance terminal theme and diagnostic dashboard for macOS (Zsh) and Windows (PowerShell 7+).

✨ Features

Real-time Diagnostics: View Battery, CPU usage, and Disk space every time you open a terminal.

Session Tracking: Displays a "Start Time" so you know exactly when you began your session.

Cross-Platform: Tailored experiences for both Mac and Windows environments.

Ultra-Clean Prompt: Minimalist cyan-themed prompt showing user@machine.

🚀 Installation
🍎 For macOS (Zsh)

Run the following command in your terminal:

Bash
```curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh | bash```

🪟 For Windows (PowerShell 7+)

[!IMPORTANT] This theme is designed for PowerShell 7.0 or higher (including PowerShell Preview). It is not compatible with the legacy "Windows PowerShell 5.1".

Open PowerShell 7 (or install it via ```winget install Microsoft.PowerShell```).

Run the installer:

PowerShell
```Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.ps1'))```

in zsh you will have to install lolcat using homebrew using the command ```brew install lolcat```

🛠️ Customization
The main configuration logic is stored in:

Mac: ~/.aurora_theme.sh (sourced in your .zshrc)

Windows: $PROFILE (usually located in Documents\PowerShell\Microsoft.PowerShell_profile.ps1)
