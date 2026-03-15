#!/bin/bash

# --- AURORA-SHELL MASTER INSTALLER v4.6.0 ---
# Logic: Zsh-Native | Multi-Font Support | /dev/tty Interactive

# 1. PRE-FLIGHT
echo "🔍 Checking for Homebrew..."
if command -v brew &> /dev/null; then
    eval "$(brew shellenv)"
else
    BREW_PATH="$HOME/homebrew"
    [ ! -d "$BREW_PATH" ] && mkdir -p "$BREW_PATH" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW_PATH"
    eval "$($BREW_PATH/bin/brew shellenv)"
fi

echo "🔍 Verifying Dependencies (Git, figlet, lolcat, pygments)..."
dependencies=(git figlet lolcat pygments)
for dep in "${dependencies[@]}"; do
    command -v "$dep" &> /dev/null || brew install "$dep"
done

INSTALL_PATH="$HOME/.aurora-shell"
mkdir -p "$INSTALL_PATH"

# 2. THE TYPOGRAPHY CHOICE
echo -e "\n\033[36m🎨 Choose your Header Typography:\033[0m"
echo "1) Standard (Retro Block)"
echo "2) Slant    (Modern Speed)"
read style_choice < /dev/tty

if [ "$style_choice" == "2" ]; then
    HEADER_CMD="figlet -f slant \"\$ascii\" | lolcat"
    echo -e "✅ \033[32mSlant Font Selected.\033[0m"
else
    HEADER_CMD="figlet \"\$ascii\" | lolcat"
    echo -e "✅ \033[32mStandard Font Selected.\033[0m"
fi

# 3. INTERACTIVE CREDENTIALS
echo -e "\n\033[35m🔐 Set Terminal Lock Password (Leave blank for NONE)\033[0m"
read -rs -p "Password: " NEW_PASS < /dev/tty && echo

# 4. GENERATE THEME ENGINE (Zsh-Specific)
THEME_FILE="$INSTALL_PATH/aurora_theme.sh"

if [ -n "$NEW_PASS" ]; then
    LOCK_FUNC="Show-AuroraLock() {
    echo -e \"\033[35m🔐 Aurora-Shell Lock\033[0m\"
    attempts=0
    while [ \$attempts -lt 3 ]; do
        read -rs \"input_pass?Password: \"
        echo
        if [ \"\$input_pass\" = \"$NEW_PASS\" ]; then
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

cat << EOF > "$THEME_FILE"
#!/bin/zsh
$LOCK_FUNC

# Aurora Pro Tools
alias acat='pygmentize -g -O style=monokai,linenos=1'

Show-AuroraDisplay() {
    battery=\$(pmset -g batt | grep -Eo \"\d+%\" | head -1)
    cpu=\$(top -l 1 | grep \"CPU usage\" | awk '{print \$3}' | sed 's/%//')
    disk=\$(df -h / | awk 'NR==2 {print \$4}')
    window_width=\$(tput cols)
    stats_line=\"📅 \$(date +'%m/%d/%y') | 🔋 \$battery | 🧠 CPU: \${cpu}% | 💽 \${disk} Free\"
    padding_val=\$(( (window_width - \${#stats_line}) / 2 ))
    padding=\$(printf '%*s' \"\$padding_val\")
    
    ascii=\"Aurora-shell\"
    $HEADER_CMD
    echo -e \"\033[36m\$padding\$stats_line\033[0m\"
    echo -e \"\033[35mYash Behera ✨ ~ \$\033[0m\"
}

clear
Show-AuroraLock
Show-AuroraDisplay
EOF

# 5. REPO CLONE & SOURCE
chmod +x "$THEME_FILE"
[ -d "$INSTALL_PATH/repo" ] && rm -rf "$INSTALL_PATH/repo"
git clone --progress https://github.com/YashB-byte/aurora-shell.git "$INSTALL_PATH/repo"

sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[32m✨ aurora-shell v4.6.0 Full Setup Complete!\033[0m"
