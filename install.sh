#!/bin/bash

# --- AURORA-SHELL MASTER v5.5.8 ---
# FULL BLOCK ART + OPTIONAL PASS + STD USER LOCK
INSTALL_DIR="$HOME/.aurora-shell"
CONFIG_FILE="$INSTALL_DIR/.aurora-shell_settings"
THEME_FILE="$INSTALL_DIR/aurora_theme.sh"
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

mkdir -p "$INSTALL_DIR"

echo -e "\033[1;36m🌟 Aurora-Shell Universal Installer v5.5.8\033[0m"

# --- SMART SYSTEM SYNC ---
sync_system() {
    echo -ne "\033[1;33m🛠️  Checking Environment... \033[0m"
    if ! command -v brew &> /dev/null; then
        if sudo -n true 2>/dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            mkdir -p "$HOME/.brew" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.brew"
            export PATH="$HOME/.brew/bin:$PATH"
        fi
    fi
    brew install figlet lolcat 2>/dev/null
    echo -e "\033[1;32mREADY\033[0m"
}
sync_system

# --- CONFIGURATION WIZARD ---
if [ -t 0 ]; then
    echo -e "\n\033[1;32m--- STEP 1: SECURITY LOCK ---\033[0m"
    echo "Leave blank and press Enter for NO password."
    read -s -p "🔐 Set Terminal Password/PIN(leave blank for none): " TERM_PW < /dev/tty
    echo ""
    
    echo -e "\n\033[1;32m--- STEP 2: HEADER CHOICE ---\033[0m"
    echo "1) The Mega-Block (Aurora-Shell Original)"
    echo "2) Custom Text (Large Slant Font)"
    read -p "Selection [1-2]: " choice < /dev/tty
    
    if [ "$choice" == "2" ]; then
        HDR_MODE="CUSTOM"
        read -p "✍️  Enter Header Name: " HDR_VAL < /dev/tty
    else
        HDR_MODE="BLOCK"
        HDR_VAL="Aurora-Shell"
    fi

    echo -e "\n\033[1;32m--- STEP 3: PERSONALIZATION ---\033[0m"
    read -p "🎂 Birthday (MMDD): " BDAY < /dev/tty
    read -p "🆔 Prompt Name: " P_ID < /dev/tty
    [ -z "$BDAY" ] && BDAY="0000"
    [ -z "$P_ID" ] && P_ID="Aurora-Shell"
else
    TERM_PW=""; HDR_MODE="BLOCK"; HDR_VAL="Aurora-Shell"; BDAY="0000"; P_ID="Aurora-Shell"
fi

cat << EOF > "$CONFIG_FILE"
AURORA_VER="5.5.8"
AURORA_PW="$TERM_PW"
AURORA_HDR_MODE="$HDR_MODE"
AURORA_HDR_VAL="$HDR_VAL"
AURORA_USER_BDAY="$BDAY"
AURORA_ID="$P_ID"
EOF

# --- THEME ENGINE ---
cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
SETTING_PATH="$HOME/.aurora-shell/.aurora-shell_settings"
[ ! -f "$SETTING_PATH" ] && return
source "$SETTING_PATH"

# --- OPTIONAL VAULT ---
authenticate_user() {
    # If password is empty string, skip authentication
    if [[ -z "$AURORA_PW" ]]; then
        return
    fi

    clear
    echo -e "\033[1;31m╔════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;31m║       AURORA SECURITY TERMINAL         ║\033[0m"
    echo -e "\033[1;31m╚════════════════════════════════════════╝\033[0m"
    echo -ne "\033[1;33m🔑 Enter Access Key: \033[0m"
    read -s input_pw
    echo ""
    
    if [[ "$input_pw" != "$AURORA_PW" ]]; then
        echo -e "\n\033[1;41m ACCESS DENIED \033[0m"
        sleep 1
        authenticate_user
    fi
}

get_motd() {
    local today=$(date +%m%d)
    if [ "$today" = "$AURORA_USER_BDAY" ]; then echo "HAPPY BIRTHDAY! 🎂" && return; fi
    case "$today" in
        0101) echo "Happy New Year 🎆" ;;
        0317) echo "St. Patrick's Day 🍀" ;;
        1225) echo "Christmas Day 🎄" ;;
    esac
}

Show-AuroraDisplay() {
    source "$HOME/.aurora-shell/.aurora-shell_settings"
    window_width="$(tput cols)"
    
    if [ "$AURORA_HDR_MODE" = "BLOCK" ]; then
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
    else
        figlet -f slant "$AURORA_HDR_VAL" | lolcat
    fi
    
    battery="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 2>/dev/null || echo '100%')"
    cpu_usage="$(top -l 1 | grep 'CPU usage' | awk '{print $3}' | sed 's/%//')%"
    stats_line="🔋 $battery | 🧠 CPU: $cpu_usage | 📅 $(date +'%m/%d/%y')"
    padding="$(printf '%*s' $(((window_width-${#stats_line})/2)))"
    echo -e "\033[36m${padding}${stats_line}\033[0m"
    
    m=$(get_motd)
    if [ ! -z "$m" ]; then
        m_pad="$(printf '%*s' $(((window_width-${#m})/2)))"
        echo -e "\033[1;93m${m_pad}✨ $m ✨\033[0m"
    fi
    printf '\033[34m%*s\n\033[0m' "$window_width" '' | tr ' ' '-'
}

shell.aurora() {
    if [[ -z "$1" ]]; then
        echo -e "\n\033[1;35m--- Aurora Help Center ---\033[0m"
        echo -e "1) --display   : Refresh Header"
        echo -e "2) --uninstall : Remove Shell"
        echo -ne "\nOption [1-2]: "
        read opt
        case $opt in
            1) Show-AuroraDisplay ;;
            2) shell.aurora --uninstall ;;
        esac
        return
    fi
    case "$1" in
        --display) Show-AuroraDisplay ;;
        --uninstall)
            sed -i '' '/aurora_theme.sh/d' ~/.zshrc
            rm -rf "$HOME/.aurora-shell"
            echo "Uninstalled." ;;
    esac
}
alias aurora="shell.aurora"

rainbow_prompt() {
  source "$HOME/.aurora-shell/.aurora-shell_settings"
  local raw_text="${AURORA_ID} %n@%m $(date +%H:%M:%S) > "
  local expanded_text=$(print -P "$raw_text")
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  for (( j=0; j<${#expanded_text}; j++ )); do
    out+="%{%F{${colors[$(( (j % ${#colors}) + 1 ))]}}%}${expanded_text:$j:1}%{%f%}"
  done
  echo -n "$out"
}

# --- INITIALIZE ---
authenticate_user
setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'
Show-AuroraDisplay
EOF

# --- INTEGRATION ---
sed -i '' '/aurora_theme.sh/d' ~/.zshrc 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[1;32m✅ v5.5.8 Deployed. Security is now user-configurable.\033[0m"