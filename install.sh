#!/bin/bash
set -e 

# Check if we are running in a Terminal or a Script
if [ -t 0 ]; then
    echo -e "\033[0;35m🔐 Aurora Security Check\033[0m"
    read -sp "Enter Deployment Password: " user_input </dev/tty
    echo "" 
    if [ "$user_input" != "$CORRECT_PASSWORD" ]; then
        echo -e "\033[0;31m❌ Access Denied.\033[0m"
        exit 1
    fi
else
    echo "🤖 Automated environment detected. Skipping password check."
fi

# --- REST OF YOUR INSTALL LOGIC ---
REPO_URL="https://github.com"
INSTALL_PATH="$HOME/.aurora-shell_2theme"
TEMP_PATH="/tmp/aurora-tmp"

rm -rf "$TEMP_PATH"
echo "📥 Fetching latest files from GitHub..."
git clone "$REPO_URL" "$TEMP_PATH"

mkdir -p "$INSTALL_PATH"
cp -rf "$TEMP_PATH"/* "$INSTALL_PATH/"
rm -rf "$TEMP_PATH"

echo "🎨 Writing Theme and Block Art..."
cat << 'EOF' > "$INSTALL_PATH/aurora_theme.sh"
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
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

ZSH_CONFIG="$HOME/.zshrc"
if ! grep -q "source $INSTALL_PATH/aurora_theme.sh" "$ZSH_CONFIG"; then
    echo "source $INSTALL_PATH/aurora_theme.sh" >> "$ZSH_CONFIG"
fi

echo -e "\033[0;32m✨ Success! Aurora Shell is deployed.\033[0m"
