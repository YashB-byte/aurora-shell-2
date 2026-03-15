#!/bin/bash

# --- AURORA-SHELL MASTER INSTALLER v4.6.2 ---
# Feature: Dynamic "ANSI Shadow" Generator to match original branding

# 1. SETUP PATHS
INSTALL_PATH="$HOME/.aurora-shell"
mkdir -p "$INSTALL_PATH"

# 2. DEPENDENCIES
echo "🔍 Checking for figlet & lolcat..."
command -v brew &> /dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null

for dep in figlet lolcat pygments git; do
    command -v "$dep" &> /dev/null || brew install "$dep"
done

# 3. DOWNLOAD THE "ANSI SHADOW" FONT (The key to your style)
FONT_FILE="$INSTALL_PATH/ansi_shadow.flf"
if [ ! -f "$FONT_FILE" ]; then
    echo "📥 Downloading Aurora Block Font..."
    curl -s -o "$FONT_FILE" "https://raw.githubusercontent.com/xshrim/figlet-fonts/master/ANSI%20Shadow.flf"
fi

# 4. INTERACTIVE NAME GATHERING
echo -e "\n\033[33m✍️  What name should appear in the Aurora header?\033[0m"
read USER_NAME < /dev/tty
[ -z "$USER_NAME" ] && USER_NAME="Aurora"

# GENERATE THE ART USING THE DOWNLOADED FONT
# This creates the exact "Double Line" look you have
ASCII_CONTENT=$(figlet -d "$INSTALL_PATH" -f "ansi_shadow" "$USER_NAME")

echo -e "\n\033[35m🔐 Set Terminal Lock Password (Leave blank for NONE)\033[0m"
read -rs -p "Password: " NEW_PASS < /dev/tty && echo

# 5. GENERATE THEME ENGINE
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

alias acat='pygmentize -g -O style=monokai,linenos=1'

Show-AuroraDisplay() {
    battery="\$(pmset -g batt | grep -Eo '[0-9]+%' | head -1)"
    cpu="\$(top -l 1 | grep 'CPU usage' | awk '{print \$3}' | sed 's/%//')"
    disk="\$(df -h / | awk 'NR==2 {print \$4}')"
    window_width="\$(tput cols)"
    stats_line="📅 \$(date +'%m/%d/%y') | 🔋 \$battery | 🧠 CPU: \${cpu}% | 💽 \${disk} Free"
    
    # RENDER GENERATED ART
    echo "$ASCII_CONTENT" | lolcat
    
    # Stats Line
    padding_val=\$(( (window_width - \${#stats_line}) / 2 ))
    padding="\$(printf '%*s' \"\$padding_val\")"
    echo -e \"\033[36m\${padding}\${stats_line}\033[0m\"
    echo -e \"\033[35mYash Behera ✨ ~ \$\033[0m\"
}

clear
Show-AuroraLock
Show-AuroraDisplay
EOF

# 6. REPO SYNC & SOURCE
chmod +x "$THEME_FILE"
[ -d "$INSTALL_PATH/repo" ] && rm -rf "$INSTALL_PATH/repo"
git clone --progress https://github.com/YashB-byte/aurora-shell.git "$INSTALL_PATH/repo"

sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[32m✨ aurora-shell v4.6.2 Installed with Custom Block Art!\033[0m"
