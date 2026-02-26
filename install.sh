#!/bin/bash
# --- AURORA SYSTEM INSTALLER ---

# 1. SET PASSWORD
echo -e "\033[0;35m🌌 Aurora Setup: Set your Terminal Lock Password\033[0m"
read -rs -p "Set new Terminal Password: " NEW_PASS </dev/tty
echo ""
read -rs -p "Confirm Password: " CONFIRM_PASS </dev/tty
echo ""

if [ "$NEW_PASS" != "$CONFIRM_PASS" ]; then
    echo -e "\033[0;31m❌ Passwords do not match. Installation aborted.\033[0m"
    exit 1
fi

# 2. FILE SETUP
INSTALL_PATH="$HOME/.aurora-shell_2theme"
mkdir -p "$INSTALL_PATH"

# 3. GENERATE THE THEME FILE
printf 'CORRECT_PASSWORD="%s"\n' "$NEW_PASS" > "$INSTALL_PATH/aurora_theme.sh"
cat << 'EOF' >> "$INSTALL_PATH/aurora_theme.sh"
# --- SECURITY LOCK ---
echo -e "\033[0;35m🔐 Aurora Terminal Lock\033[0m"
ATTEMPTS=0
while [ $ATTEMPTS -lt 3 ]; do
    if [ -n "$ZSH_VERSION" ]; then read -rs "?Password: " ui </dev/tty; else read -rsp "Password: " ui </dev/tty; fi
    echo ""
    if [ "$(echo "$ui" | xargs)" = "$CORRECT_PASSWORD" ]; then
        echo -e "\033[0;32m✅ Access Granted.\033[0m"; break
    else
        ATTEMPTS=$((ATTEMPTS + 1))
        [ $ATTEMPTS -lt 3 ] && echo "❌ Incorrect. $((3-ATTEMPTS)) left." && sleep 2 || { echo "❌ Denied."; exit 1; }
    fi
done

# --- LOGO & STATS ---
aurora_display() {
    local battery=$(pmset -g batt 2>/dev/null | grep -Eo "\d+%" | head -1 || echo "N/A")
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
     ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝" | lolcat
    echo -e "\033[0;36m📅 $(date +%D) | 🔋 $battery | 🧠 CPU: $(top -l 1 | grep "CPU usage" | awk '{print $3}')\033[0m" | lolcat
}
aurora_display

# --- COMMANDS ---
aurora() {
    case "$1" in
        "lock") clear && source "$HOME/.aurora-shell_2theme/aurora_theme.sh" ;;
        "pass") # (Add password change logic here) ;;
        *) echo "Usage: aurora [lock|pass] | shell.aurora?help" ;;
    esac
}
alias "shell.aurora?help"="aurora"
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

# 4. LINK TO ZSHRC
ZSH_CONFIG="$HOME/.zshrc"
grep -q "aurora_theme.sh" "$ZSH_CONFIG" || echo "source $INSTALL_PATH/aurora_theme.sh" >> "$ZSH_CONFIG"

echo -e "\033[0;32m✨ Aurora Installed!\033[0m"
