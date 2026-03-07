#!/bin/bash
# --- AURORA SYSTEM INSTALLER v4.3.6 ---

# 0. VERBOSE & PRE-CLEAN
INSTALL_PATH="$HOME/.aurora-shell_2theme"
[[ -d "$INSTALL_PATH" ]] && rm -rf "$INSTALL_PATH"
mkdir -p "$INSTALL_PATH"

# 1. SET PASSWORD
echo -e "\033[0;35m🌌 Aurora Setup: Set your Terminal Lock Password\033[0m"
read -rs -p "Set new Terminal Password: " NEW_PASS </dev/tty
echo ""
read -rs -p "Confirm Password: " CONFIRM_PASS </dev/tty
echo ""

[[ "$NEW_PASS" != "$CONFIRM_PASS" ]] && echo "❌ Mismatch!" && exit 1

# 2. DEPENDENCY CHECK
echo "🔍 Checking for required tools..."
for tool in lolcat pygmentize git; do
    command -v $tool &>/dev/null || brew install $tool || pip3 install $tool
done

# 3. CLONE
echo "📥 Cloning Aurora Shell..."
git clone --progress https://github.com/YashB-byte/aurora-shell-2.git "$INSTALL_PATH/repo"

# 4. GENERATE THEME
printf 'CORRECT_PASSWORD="%s"\n' "$NEW_PASS" > "$INSTALL_PATH/aurora_theme.sh"

cat << 'EOF' >> "$INSTALL_PATH/aurora_theme.sh"
# --- AURORA SECURITY LOCK ---
echo -e "\033[0;35m🔐 Aurora Terminal Lock\033[0m"
ATTEMPTS=0
while [ $ATTEMPTS -lt 3 ]; do
    if [ -n "$ZSH_VERSION" ]; then read -rs "ui?Password: " </dev/tty; else read -rsp "Password: " ui </dev/tty; fi
    echo ""
    if [ "$(echo "$ui" | xargs)" = "$CORRECT_PASSWORD" ]; then
        echo -e "\033[0;32m✅ Access Granted.\033[0m"; break
    else
        ATTEMPTS=$((ATTEMPTS + 1))
        [[ $ATTEMPTS -eq 3 ]] && echo "❌ Access Denied." && exit 1
    fi
done

# --- CENTERED DISPLAY ---
aurora_display() {
    local date_str=$(date +"%m/%d/%y")
    local battery=$(pmset -g batt 2>/dev/null | grep -Eo "\d+%" | head -1 || echo "N/A")
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local free_space=$(df -h / | awk 'NR==2 {print $4}')
    
    local stats_line="📅 $date_str | 🔋 $battery | 🧠 CPU: $cpu_usage% | 📂 Free: $free_space"
    local term_width=$(tput cols)

    echo -e "
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
                 ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝" | lolcat

    printf "%*s\n" $(( (${#stats_line} + term_width) / 2 )) "$stats_line" | lolcat
    echo ""
}

clear && aurora_display

[[ -f "$HOME/.aurora-shell_2theme/repo/aurora_core.sh" ]] && source "$HOME/.aurora-shell_2theme/repo/aurora_core.sh"
EOF

# 5. LINK TO ZSHRC
if ! grep -q "aurora_theme.sh" "$HOME/.zshrc"; then
    echo "source $INSTALL_PATH/aurora_theme.sh" >> "$HOME/.zshrc"
fi

echo -e "\033[0;32m✨ Installation complete. Run 'source ~/.zshrc' to activate.\033[0m"
