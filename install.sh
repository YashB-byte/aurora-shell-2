#!/bin/bash
# --- AURORA SYSTEM INSTALLER v4.0.0 ---

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

# 2. DEPENDENCY CHECK
echo "🔍 Checking for required tools..."
for tool in lolcat pygmentize; do
    if ! command -v $tool &> /dev/null; then
        echo "📥 $tool not found. Attempting install..."
        brew install $tool || pip3 install $tool || echo "⚠️ Please install $tool manually."
    fi
done

# 3. FILE SETUP
INSTALL_PATH="$HOME/.aurora-shell_2theme"
mkdir -p "$INSTALL_PATH"

# 4. GENERATE THE THEME FILE
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

# --- THE INTERACTIVE COMMAND CENTER ---
shell.aurora() {
    case "$1" in
        "lock"|"--lock") 
            clear && source "$HOME/.aurora-shell_2theme/aurora_theme.sh" ;;
        "pass"|"--pass")
            if [ -n "$ZSH_VERSION" ]; then read -rs "?Current Pass: " op; else read -rsp "Current Pass: " op; fi
            echo ""
            if [ "$op" = "$CORRECT_PASSWORD" ]; then
                if [ -n "$ZSH_VERSION" ]; then read -rs "?New Pass: " np; else read -rsp "New Pass: " np; fi
                echo ""
                sed -i '' "s/CORRECT_PASSWORD=\".*\"/CORRECT_PASSWORD=\"$np\"/" "$HOME/.aurora-shell_2theme/aurora_theme.sh"
                CORRECT_PASSWORD="$np" && echo "✅ Updated!"
            else
                echo "❌ Wrong password."
            fi ;;
        "update"|"--update")
            local VER=${2:-"main"}
            echo -e "\033[0;35m🔄 Updating Aurora to version: $VER...\033[0m"
            curl -s "https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/$VER/install.sh" | bash
            ;;
        *) 
            echo -e "\033[1;35m🌌 Aurora Command Center\033[0m"
            echo "---------------------------------------"
            echo -e "🚀 [1] lock   : Re-engage terminal lock"
            echo -e "🔑 [2] pass   : Change your password"
            echo -e "🔄 [3] update : Pull latest from GitHub"
            echo -e "❓ [4] help   : Show this manual"
            echo "---------------------------------------"
            echo -en "\033[0;36mSelect an option (1-4): \033[0m"
            read -r choice
            case "$choice" in
                1) shell.aurora lock ;;
                2) shell.aurora pass ;;
                3) shell.aurora update ;;
                4|*) echo -e "Usage: shell.aurora [lock|pass|update]" ;;
            esac
            ;;
    esac
}

alias aurora="shell.aurora"
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

# 5. LINK TO ZSHRC
ZSH_CONFIG="$HOME/.zshrc"
grep -q "aurora_theme.sh" "$ZSH_CONFIG" || echo "source $INSTALL_PATH/aurora_theme.sh" >> "$ZSH_CONFIG"

echo -e "\033[0;32m✨ Aurora Installed! Run 'source ~/.zshrc' or open a new tab.\033[0m"
