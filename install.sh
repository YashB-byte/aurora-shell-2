#!/bin/bash

# --- AURORA-SHELL SYSTEM INSTALLER (macOS/Zsh) v4.5.9 ---
# Fixed: Zsh Syntax, Renamed Paths, Forced /dev/tty Input

echo "🔍 Checking for Homebrew..."
install_local_brew() {
    BREW_PATH="$HOME/homebrew"
    [ ! -d "$BREW_PATH" ] && mkdir -p "$BREW_PATH" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW_PATH"
    eval "$($BREW_PATH/bin/brew shellenv)"
}
command -v brew &> /dev/null && eval "$(brew shellenv)" || install_local_brew

echo "🔍 Verifying Dependencies (Git, figlet, lolcat, pygments)..."
dependencies=(git figlet lolcat pygments)
for dep in "${dependencies[@]}"; do
    command -v "$dep" &> /dev/null || brew install "$dep"
done

# RENAMED PATH
INSTALL_PATH="$HOME/.aurora-shell"
mkdir -p "$INSTALL_PATH"

# INTERACTIVE SETUP (Forcing /dev/tty so curl|bash works)
echo -e "\033[36m🎨 Choose your header style:\033[0m"
echo "1) Block (Classic Aurora)"
echo "2) Slant (Personalized Name)"
read style_choice < /dev/tty

USER_NAME="aurora-shell"
if [ "$style_choice" == "2" ]; then
    echo -e "\n\033[33m✍️  What name should appear in the header?\033[0m"
    read USER_NAME < /dev/tty
fi

echo -e "\n\033[35m🔐 Set Terminal Lock Password (Leave blank for NONE)\033[0m"
read -rs -p "Password: " NEW_PASS < /dev/tty && echo

# GENERATE THEME ENGINE
THEME_FILE="$INSTALL_PATH/aurora_theme.sh"

if [ -n "$NEW_PASS" ]; then
    # ZSH COMPATIBLE READ
    LOCK_FUNC="Show-AuroraLock() {
    echo -e \"\033[35m🔐 Aurora-Shell Lock\033[0m\"
    attempts=0
    while [ \$attempts -lt 3 ]; do
        read -rs \"input_pass?Password: \"
        echo
        if [ \"\$input_pass\" == \"$NEW_PASS\" ]; then
            echo -e \"\033[32m✅ Access Granted.\033[0m\"
            return 0
        else
            attempts=\$((attempts + 1))
            echo -e \"\033[31m❌ Incorrect. \$((3 - attempts)) left.\033[0m\"
            if [ \$attempts -eq 3 ]; then kill -9 \$\$; fi
        fi
    done
}"
else
    LOCK_FUNC="Show-AuroraLock() { :; }"
fi

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
    ASCII_CONTENT="$USER_NAME"
    HEADER_CMD="figlet -f slant \"\$ascii\" | lolcat"
fi

cat << EOF > "$THEME_FILE"
#!/bin/zsh
$LOCK_FUNC

alias acat='pygmentize -g -O style=monokai,linenos=1'

Show-AuroraDisplay() {
    battery=\$(pmset -g batt | grep -Eo \"\d+%\" | head -1)
    cpu=\$(top -l 1 | grep \"CPU usage\" | awk '{print \$3}' | sed 's/%//')
    disk=\$(df -h / | awk 'NR==2 {print \$4}')
    window_width=\$(tput cols)
    stats_line=\"📅 \$(date +'%m/%d/%y') | 🔋 \$battery | 🧠 CPU: \${cpu}% | 💽 \${disk} Free\"
    padding_val=\$(( (window_width - \${#stats_line}) / 2 ))
    padding=\$(printf '%*s' \"\$padding_val\")
    ascii=\"$ASCII_CONTENT\"
    $HEADER_CMD
    echo -e \"\033[36m\$padding\$stats_line\033[0m\"
    echo -e \"\033[35mYash Behera ✨ ~ \$\033[0m\"
}

clear
Show-AuroraLock
Show-AuroraDisplay
EOF

chmod +x "$THEME_FILE"
[ -d "$INSTALL_PATH/repo" ] && rm -rf "$INSTALL_PATH/repo"
# UPDATED REPO URL
git clone --progress https://github.com/YashB-byte/aurora-shell.git "$INSTALL_PATH/repo"

sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[32m✨ aurora-shell v4.5.9 Installed!\033[0m"
