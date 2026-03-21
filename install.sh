#!/bin/bash
# --- AURORA-SHELL MASTER v5.7.4 ---
# VERSION: 5.7.4
# FIX: Dynamic Width Sensing for Perfect Centering

INSTALL_DIR="$HOME/.aurora-shell"
CONFIG_FILE="$INSTALL_DIR/.aurora-shell_settings"
THEME_FILE="$INSTALL_DIR/aurora_theme.sh"
REMOTE_URL="https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh"

mkdir -p "$INSTALL_DIR"

# --- SYNC ENVIRONMENT ---
sync_env() {
    echo -ne "\033[1;33m🛠️  Syncing Environment... \033[0m"
    if ! command -v brew &> /dev/null; then
        mkdir -p "$HOME/.brew" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.brew"
        export PATH="$HOME/.brew/bin:$PATH"
    fi
    brew install figlet lolcat 2>/dev/null
    echo -e "\033[1;32mREADY\033[0m"
}

# --- THE WIZARD ---
run_wizard() {
    echo -e "\n\033[1;32m--- AURORA CONFIGURATION WIZARD ---\033[0m"
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
    
    read -s -p "🔐 Set Terminal PIN (Enter for none): " NEW_PW < /dev/tty; echo ""
    echo "🎨 1) Mega-Block 2) Custom Slant"
    read -p "Selection: " choice < /dev/tty
    if [ "$choice" == "2" ]; then 
        HDR_MODE="CUSTOM"
        read -p "✍️ Header Name: " HDR_VAL < /dev/tty
    else 
        HDR_MODE="BLOCK"
        HDR_VAL="Aurora-Shell"
    fi
    read -p "🎂 Birthday (MMDD): " BDAY < /dev/tty
    read -p "🆔 Prompt ID: " P_ID < /dev/tty

    cat << EOF > "$CONFIG_FILE"
AURORA_VER="5.7.4"
AURORA_PW="${NEW_PW:-$AURORA_PW}"
AURORA_HDR_MODE="$HDR_MODE"
AURORA_HDR_VAL="$HDR_VAL"
AURORA_USER_BDAY="${BDAY:-$AURORA_USER_BDAY}"
AURORA_ID="${P_ID:-$AURORA_ID}"
EOF
}

# --- THEME ENGINE ---
generate_theme() {
    cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
source "$HOME/.aurora-shell/.aurora-shell_settings"

# -- THE VAULT --
authenticate_user() {
    local target_pw="${1:-$AURORA_PW}"
    if [[ -z "$target_pw" && -z "$1" ]]; then return; fi
    clear
    echo "          .---.
         /     \\
        | (00)  |  SYSTEM ENCRYPTED
         \\  ^  /
          '---'
    ╔════════════════════════════════════════╗
    ║     AURORA-SHELL SECURITY TERMINAL     ║
    ╚════════════════════════════════════════╝" | lolcat
    while true; do
        echo -ne "\033[1;36m[AUTH] Key: \033[0m"; read -s in_pw; echo ""
        [[ "$in_pw" == "$target_pw" ]] && { clear; break; } || echo -e "\033[1;41m DENIED \033[0m"
    done
}

# -- CENTERED DISPLAY ENGINE --
Show-Aurora() {
    source "$HOME/.aurora-shell/.aurora-shell_settings"
    local cols=$(tput cols)
    local content=""

    if [ "$AURORA_HDR_MODE" = "BLOCK" ]; then
        content="
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
    else
        content=$(figlet -f slant "$AURORA_HDR_VAL")
    fi

    # FIND MAX WIDTH OF BLOCK
    local max_w=0
    while IFS= read -r line; do
        local len=${#line}
        (( len > max_w )) && max_w=$len
    done <<< "$content"

    # CALCULATE PADDING
    local pad=$(( (cols - max_w) / 2 ))
    [[ $pad -lt 0 ]] && pad=0

    # PRINT CENTERED HEADER
    while IFS= read -r line; do
        printf "%${pad}s%s\n" "" "$line"
    done <<< "$content" | lolcat

    # STATS LINE
    local batt=$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 || echo "100%")
    local cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}' || echo "0%")
    local stats="🔋 $batt | 🧠 CPU: $cpu | 📅 $(date +'%m/%d/%y')"
    local s_pad=$(( (cols - ${#stats}) / 2 ))
    [[ $s_pad -lt 0 ]] && s_pad=0
    printf "%${s_pad}s\033[1;36m%s\033[0m\n" "" "$stats"

    # RAINBOW RULE
    local line_str=""
    for ((i=1; i<=$cols; i++)); do line_str+="-"; done
    echo "$line_str" | lolcat
}

# -- COMMAND CENTER --
shell.aurora() {
    case "$1" in
        --display) Show-Aurora ;;
        --update)
            local r_ver=$(curl -s "$REMOTE_URL" | grep -m1 'VERSION:' | awk '{print $3}')
            if [[ "$2" == "--force" ]] || [[ "$r_ver" > "$AURORA_VER" ]]; then
                bash <(curl -s "$REMOTE_URL") --force
            else
                echo "Up to date (v$AURORA_VER)."
            fi
            ;;
        --sys) sw_vers && sysctl -n machdep.cpu.brand_string ;;
        --net) echo "IP: $(curl -s ifconfig.me)" ;;
        --lock) authenticate_user "MANUAL" && Show-Aurora ;;
        --uninstall) rm -rf "$HOME/.aurora-shell" && sed -i '' '/aurora_theme/d' ~/.zshrc ;;
        *) echo "Flags: --display, --update, --sys, --net, --lock, --uninstall" ;;
    esac
}
alias aurora="shell.aurora"

# -- RAINBOW PROMPT --
rainbow_prompt() {
  local raw_text="${AURORA_ID} %n@%m %* > "
  local expanded_text=$(print -P "$raw_text")
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  for (( j=0; j<${#expanded_text}; j++ )); do
    out+="%{%F{${colors[$(( (j % ${#colors}) + 1 ))]}}%}${expanded_text:$j:1}%{%f%}"
  done
  echo -n "$out"
}

authenticate_user
setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'
Show-Aurora
EOF
}

# --- EXECUTE ---
sync_env
run_wizard
generate_theme
sed -i '' '/aurora_theme.sh/d' ~/.zshrc 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"
echo -e "\n\033[1;32m✅ v5.7.4 Sentinel Deployed. Perfect alignment confirmed.\033[0m"