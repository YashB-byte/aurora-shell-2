#!/bin/bash

# --- AURORA-SHELL MASTER v5.4.6 ---
# UPDATED PATHS: All files now live inside the hidden directory
INSTALL_DIR="$HOME/.aurora-shell"
CONFIG_FILE="$INSTALL_DIR/.aurora-shell_settings"
THEME_FILE="$INSTALL_DIR/aurora_theme.sh"

mkdir -p "$INSTALL_DIR"

echo -e "\033[1;36m🌟 Aurora-Shell Universal Installer v5.4.6\033[0m"

# --- SMART DEPENDENCY ENGINE ---
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
    brew install git figlet lolcat 2>/dev/null
    echo -e "\033[1;32mREADY\033[0m"
}
sync_system

# --- CONFIGURATION WIZARD ---
if [ -t 0 ]; then
    echo -e "\n\033[1;32m--- STEP 1: HEADER STYLE ---\033[0m"
    read -p "✍️  Enter Header Name: " HEADER_TEXT < /dev/tty
    [ -z "$HEADER_TEXT" ] && HEADER_TEXT="Aurora-Shell"

    echo -e "\n\033[1;32m--- STEP 2: PERSONALIZATION ---\033[0m"
    read -p "🎂 Birthday (MMDD): " USER_BDAY < /dev/tty
    [ -z "$USER_BDAY" ] && USER_BDAY="0000"

    read -p "🆔 Prompt Name: " FINAL_ID < /dev/tty
    [ -z "$FINAL_ID" ] && FINAL_ID="Aurora"
else
    HEADER_TEXT="Aurora-Shell"; USER_BDAY="0000"; FINAL_ID="Aurora"
fi

# --- SAVE SETTINGS (Nested Path) ---
cat << EOF > "$CONFIG_FILE"
AURORA_VER="5.4.6"
AURORA_HEADER_TEXT="$HEADER_TEXT"
AURORA_USER_BDAY="$USER_BDAY"
AURORA_ID="$FINAL_ID"
EOF

# --- GENERATE THEME ENGINE ---
cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
# Path to nested settings
SETTING_PATH="$HOME/.aurora-shell/.aurora-shell_settings"
[ ! -f "$SETTING_PATH" ] && return
source "$SETTING_PATH"

get_cpu() {
    echo "$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')%"
}

get_motd() {
    local today=$(date +%m%d)
    if [ "$today" = "$AURORA_USER_BDAY" ]; then
        echo "HAPPY BIRTHDAY! 🎂"
        return
    fi
    case "$today" in
        0101) echo "Happy New Year 🎆" ;;
        1031) echo "Halloween 🎃" ;;
        1225) echo "Christmas Day 🎄" ;;
        *) echo "" ;; 
    esac
}

Show-AuroraDisplay() {
    window_width="$(tput cols)"
    figlet -f slant "$AURORA_HEADER_TEXT" | lolcat
    
    battery="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 2>/dev/null || echo '100%')"
    stats_line="🔋 $battery | 🧠 CPU: $(get_cpu) | 📅 $(date +'%m/%d/%y')"
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
    SETTING_PATH="$HOME/.aurora-shell/.aurora-shell_settings"
    source "$SETTING_PATH"
    case "$1" in
        --version) echo "📦 Aurora-Shell v$AURORA_VER" ;;
        --uninstall)
            sed -i '' '/aurora_theme.sh/d' ~/.zshrc
            rm -rf "$HOME/.aurora-shell"
            echo "🗑️  Full cleanup complete." ;;
        *) clear && Show-AuroraDisplay ;;
    esac
}
alias aurora="shell.aurora"

rainbow_prompt() {
  SETTING_PATH="$HOME/.aurora-shell/.aurora-shell_settings"
  if [ ! -f "$SETTING_PATH" ]; then
    echo -n "Aurora > "
    return
  fi
  source "$SETTING_PATH"
  local text="${AURORA_ID} @ $(date +%H:%M:%S) > "
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  for (( j=0; j<${#text}; j++ )); do
    out+="%{%F{${colors[$(( (j % ${#colors}) + 1 ))]}}%}${text:$j:1}%{%f%}"
  done
  echo -n "$out"
}

setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'
clear && Show-AuroraDisplay
EOF

# --- FINAL INTEGRATION ---
sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[1;32m✅ v5.4.6 Deployed. Everything is now inside ~/.aurora-shell/\033[0m"