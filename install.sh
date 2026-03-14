#!/bin/bash

# --- AURORA SYSTEM INSTALLER (macOS/Zsh) v4.5.2 ---
# Logic: Admin Brew -> User-Home Fallback | Multi-Style Header | Password Lock

# 1. PRE-FLIGHT: HOMEBREW PERMISSION & INSTALL LOGIC
echo "🔍 Checking for Homebrew..."

install_local_brew() {
    BREW_PATH="$HOME/homebrew"
    echo "⚠️ Global Brew restricted or missing. Installing to $BREW_PATH..."
    if [ ! -d "$BREW_PATH" ]; then
        mkdir -p "$BREW_PATH"
        curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW_PATH"
    fi
    eval "$($BREW_PATH/bin/brew shellenv)"
    if ! grep -q "homebrew/bin/brew shellenv" "$HOME/.zprofile"; then
        echo "eval \"\$($BREW_PATH/bin/brew shellenv)\"" >> "$HOME/.zprofile"
    fi
}

if command -v brew &> /dev/null; then
    BREW_PREFIX=$(brew --prefix)
    if [ -w "$BREW_PREFIX" ]; then
        echo "✅ Global Homebrew detected with write access."
        eval "$(brew shellenv)"
    else
        echo "🔒 Global Homebrew detected but write-access denied."
        install_local_brew
    fi
else
    echo "📥 Homebrew missing. Attempting standard installation..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
    else
        install_local_brew
    fi
fi

# 2. VERIFY DEPENDENCIES (Added figlet for slant style)
echo "🔍 Verifying Dependencies (Git, figlet, lolcat)..."
dependencies=(git figlet lolcat)
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo "📥 Installing $dep..."
        brew install "$dep"
    fi
done

INSTALL_PATH="$HOME/.aurora-shell_2theme"

# 3. STYLE SELECTION & CREDENTIALS
if [[ -t 0 ]]; then
    echo -e "\033[36m🎨 Choose your header style:\033[0m"
    echo "1) Block (Classic Aurora)"
    echo "2) Slant (Aurora-shell) with Lolcat"
    read -p "Enter choice [1 or 2]: " style_choice
    
    echo -e "\n\033[35m🌌 Aurora Setup: Set your Terminal Lock Password (Leave blank for NONE)\033[0m"
    read -rs -p "Password: " NEW_PASS < /dev/tty
    echo
else
    # Default for non-interactive installer
    style_choice="2"
    NEW_PASS=""
fi

if [ -z "$NEW_PASS" ]; then
    echo "🔓 No password set. Skipping lock screen."
    PLAIN_PASS=""
else
    read -rs -p "Confirm Password: " CONFIRM_PASS < /dev/tty
    echo
    if [ "$NEW_PASS" != "$CONFIRM_PASS" ]; then
        echo -e "\033[31m❌ Passwords do not match!\033[0m"
        exit 1
    fi
    PLAIN_PASS="$NEW_PASS"
fi

# 4. PURGE & CLONE
[ -d "$INSTALL_PATH" ] && rm -rf "$INSTALL_PATH"
mkdir -p "$INSTALL_PATH"
echo "📥 Cloning Aurora Shell v4.5.2..."
git clone --progress https://github.com/YashB-byte/aurora-shell-2.git "$INSTALL_PATH/repo"

# 5. GENERATE THEME ENGINE
THEME_FILE="$INSTALL_PATH/aurora_theme.sh"

# Build the Lock Function
if [ -n "$PLAIN_PASS" ]; then
    LOCK_FUNC="Show-AuroraLock() {
    echo -e \"\033[35m🔐 Aurora Terminal Lock\033[0m\"
    attempts=0
    while [ \$attempts -lt 3 ]; do
        read -rs -p \"Password: \" input_pass
        echo
        if [ \"\$input_pass\" == \"$PLAIN_PASS\" ]; then
            echo -e \"\033[32m✅ Access Granted.\033[0m\"
            return 0
        else
            ((attempts++))
            echo -e \"\033[33m❌ Incorrect. \$((3-attempts)) left.\033[0m\"
            if [ \$attempts -eq 3 ]; then exit; fi
        fi
    done
}"
else
    LOCK_FUNC="Show-AuroraLock() { :; }"
fi

# Define Header ASCII
if [ "$style_choice" == "1" ]; then
    ASCII_CONTENT="
  █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ 
 ██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗
 ███████║██║   ██║██████╔╝██║   ██║██████╔╝███████║
 ██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██║
 ██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║██║  ██║
 ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
                                                   
      ███████╗██╗  ██╗███████╗██╗     ██╗                
      ██╔════╝██║  ██║██╔════╝██║     ██║                
      ███████╗███████║█████╗  ██║     ██║                
      ╚════██║██╔══██║██╔══╝  ██║     ██║                
      ███████║██║  ██║███████╗███████╗███████╗          
      ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝"
    HEADER_CMD="echo \"\$ascii\" | lolcat"
else
    ASCII_CONTENT="Aurora-shell"
    HEADER_CMD="figlet -f slant \"\$ascii\" | lolcat"
fi

cat << EOF > "$THEME_FILE"
#!/bin/bash
$LOCK_FUNC

Show-AuroraDisplay() {
    if command -v pmset &> /dev/null; then
        battery=\$(pmset -g batt | grep -Eo "\d+%" | head -1)
    else
        battery="100%"
    fi
    cpu=\$(top -l 1 | grep "CPU usage" | awk '{print \$3}' | sed 's/%//')
    disk=\$(df -h / | awk 'NR==2 {print \$4}')
    window_width=\$(tput cols)
    stats_line="📅 \$(date +'%m/%d/%y') | 🔋 \$battery | 🧠 CPU: \${cpu}% | 💽 \${disk} Free"
    padding_val=\$(( (window_width - \${#stats_line}) / 2 ))
    padding=\$(printf '%*s' "\$padding_val")
    ascii="$ASCII_CONTENT"
    $HEADER_CMD
    echo -e "\033[36m\$padding\$stats_line\033[0m"
    echo -e "\033[35mYash Behera ✨ ~ \$\033[0m"
}

clear
Show-AuroraLock
Show-AuroraDisplay
EOF

chmod +x "$THEME_FILE"

# 6. SOURCE IN .ZSHRC
grep -q "source $THEME_FILE" "$HOME/.zshrc" || echo -e "\n# Aurora Shell Theme\nsource $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\033[32m✨ Aurora v4.5.2 Installed! Restart terminal to see changes.\033[0m"
