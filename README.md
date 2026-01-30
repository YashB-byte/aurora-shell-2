# 🌌 Aurora Shell

An elegant, animated Zsh theme featuring a shifting rainbow prompt, live system diagnostics, and high-fidelity ASCII art.

## 🚀 Quick Install

To install Aurora Shell automatically on your Mac, paste this into your terminal:

zsh
```/bin/bash -c "$(curl -fsSL [https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh](https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh))"```
✨ Features
🌈 Shifting Rainbow Prompt: A marquee-style prompt that cycles through "Aurora" colors every time you run a command.

📊 Live Dashboard: Real-time battery status and disk space monitoring displayed on startup.

🎨 Animated ASCII Art: A professional Aurora logo powered by lolcat animations.

⚡ Pro-Developer Defaults: Built-in support for Syntax Highlighting (know if your command is right before hitting enter) and Autosuggestions (grey "ghost text" based on your history).

🛠️ Manual Requirements
The installer handles these for you, but for reference:

Zsh (Default on macOS)

Homebrew (Required for lolcat and plugins)

iTerm2 (Highly recommended for the best color rendering)

📂 Project Structure
install.sh: The automated one-click installation script.

zsh/theme.zsh: The visual engine (Logo, Prompt, and Colors).

zsh/main.zsh: The logic engine (Battery, Disk, and Git functions).

📄 License
Distributed under the MIT License. Feel free to fork and customize!

Instructions for Windows Powershell

to get the aurora-shell use this command

```Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('[https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.ps1](https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.ps1)'))```

Proudly crafted by YashB-byte
