#!/bin/bash
set -e

# --- 1. SETUP USER CHOICE ---
echo -e "\033[0;35m🌌 Aurora Setup: Set your Terminal Lock Password\033[0m"
read -rs -p "Set new Terminal Password: " NEW_PASS </dev/tty
echo ""
read -rs -p "Confirm Password: " CONFIRM_PASS </dev/tty
echo ""

if [ "$NEW_PASS" != "$CONFIRM_PASS" ]; then
    echo -e "\033[0;31m❌ Passwords do not match. Installation aborted.\033[0m"
    exit 1
fi

# --- 2. CONFIGURATION ---
REPO_URL="https://github.com/YashB-byte/aurora-shell-2.git"
INSTALL_PATH="$HOME/.aurora-shell_2theme"
TEMP_PATH="/tmp/aurora-tmp"

# --- 3. INSTALLATION ---
rm -rf "$TEMP_PATH"
echo "📥 Fetching Aurora files..."
git clone "$REPO_URL" "$TEMP_PATH"

mkdir -p "$INSTALL_PATH"
cp -rf "$TEMP_PATH"/* "$INSTALL_PATH/"
rm -rf "$TEMP_PATH"

echo "🎨 Personalizing your Terminal Lock..."

# --- 4. GENERATE THE THEME ---
printf 'CORRECT_PASSWORD="%s"\n' "$NEW_PASS" > "$INSTALL_PATH/aurora_theme.sh"
cat << 'EOF' >> "$INSTALL_PATH/aurora_theme.sh"

echo -e "\033[0;35m🔐 Aurora Terminal Lock\033[0m"

ATTEMPTS=0
MAX_ATTEMPTS=3

while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
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
        ATTEMPTS=$((ATTEMPTS + 1))
        REMAINING=$((MAX_ATTEMPTS - ATTEMPTS))
        
        if [ $REMAINING -gt 0 ]; then
            echo -e "\033[0;31m❌ Incorrect password.\033[0m"
            echo -e "\033[0;33m⏳ Security delay active... (2s)\033[0m"
            sleep 2
            echo -e "\033[0;36m🔑 $REMAINING attempts remaining.\033[0m"
        else
            echo -e "\033[0;31m❌ Final Attempt Failed. Closing session...\033[0m"
            sleep 1
            exit 1
        fi
    fi
done

aurora_display_login() {
    local date_val=$(date +"%m/%d/%y")
    local battery=$(pmset -g batt 2>/dev/null | grep -Eo "\d+%" | head -1 || echo "N/A")
    local cpu_load=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local disk_free=$(df -h / | awk 'NR==2 {print $4}')

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
╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝  " | lolcat

    echo -e "\033[0;36m📅 $date_val | 🔋 $battery | 🧠 CPU: $cpu_load | 💽 $disk_free Free\033[0m" | lolcat
    echo "---------------------------------------------------" | lolcat
}

aurora_display_login
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

# --- 5. LINK TO ZSH ---
ZSH_CONFIG="$HOME/.zshrc"
if ! grep -q "source $INSTALL_PATH/aurora_theme.sh" "$ZSH_CONFIG"; then
    echo "source $INSTALL_PATH/aurora_theme.sh" >> "$ZSH_CONFIG"
fi

echo -e "\033[0;32m✨ Success! 3-attempt lock with delay is active.\033[0m"
