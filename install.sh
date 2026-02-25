#!/bin/bash
set -e

# --- CONFIGURATION ---
REPO_URL="https://github.com/YashB-byte/aurora-shell-2.git"
INSTALL_PATH="$HOME/.aurora-shell_2theme"
TEMP_PATH="/tmp/aurora-tmp"

# --- INSTALLATION ---
rm -rf "$TEMP_PATH"
echo "📥 Fetching Aurora files..."
git clone "$REPO_URL" "$TEMP_PATH"

mkdir -p "$INSTALL_PATH"
cp -rf "$TEMP_PATH"/* "$INSTALL_PATH/"
rm -rf "$TEMP_PATH"

echo "🎨 Installing Terminal Lock and Theme..."

# --- GENERATE THE THEME FILE ---
# CRITICAL: The word EOF at the bottom must have NO spaces before it.
cat << 'EOF' > "$INSTALL_PATH/aurora_theme.sh"
# 1. THE LOCK SYSTEM
CORRECT_PASSWORD="my-real-password-123"

echo -e "\033[0;35m🔐 Aurora Terminal Lock\033[0m"

while true; do
    # ZSH vs Bash password prompt
    if [ -n "$ZSH_VERSION" ]; then
        read -rs "?Enter Terminal Password: " user_input </dev/tty
    else
        read -rsp "Enter Terminal Password: " user_input </dev/tty
    fi
    echo "" 

    if [ "$(echo "$user_input" | xargs)" = "$CORRECT_PASSWORD" ]; then
        echo -e "\033[0;32m✅ Access Granted.\033[0m"
        break
    else
        echo -e "\033[0;31m❌ Access Denied. Closing session...\033[0m"
        sleep 1
        exit 1
    fi
done

# 2. SYSTEM STATS
aurora_stats() {
    local date_val=$(date +"%m/%d/%y")
    local battery=$(pmset -g batt 2>/dev/null | grep -Eo "\d+%" | head -1 || echo "N/A")
    local cpu_load=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local disk_free=$(df -h / | awk 'NR==2 {print $4}')

    echo -e "\033[0;36m📅 $date_val | 🔋 $battery | 🧠 CPU: $cpu_load | 💽 $disk_free Free\033[0m" | lolcat
    echo "---------------------------------------------------" | lolcat
}

# 3. THE LOGO (Simplified for reliability)
echo "
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
╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
" | lolcat

precmd() { aurora_stats }
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

# --- UPDATE ZSHRC ---
ZSH_CONFIG="$HOME/.zshrc"
if ! grep -q "source $INSTALL_PATH/aurora_theme.sh" "$ZSH_CONFIG"; then
    echo "source $INSTALL_PATH/aurora_theme.sh" >> "$ZSH_CONFIG"
fi

echo -e "\033[0;32m✨ Success! Aurora is installed and locked.\033[0m"
