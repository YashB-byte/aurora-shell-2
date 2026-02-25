#!/bin/bash
set -e

# 1. SET YOUR PASSWORD HERE
CORRECT_PASSWORD="my-real-password-123"

# Check if we are running in a Terminal or a Script
if [ -t 0 ]; then
    echo -e "\033[0;35m🔐 Aurora Security Check\033[0m"
    # Use -r to prevent backslashes from being mangled
    read -rsp "Enter Deployment Password: " user_input </dev/tty
    echo "" 
    
    # Trim potential whitespace from the input
    user_input=$(echo "$user_input" | xargs)
    
    if [ "$user_input" != "$CORRECT_PASSWORD" ]; then
        echo -e "\033[0;31m❌ Access Denied.\033[0m"
        exit 1
    fi
else
    echo "🤖 Automated environment detected. Skipping password check."
fi

# --- FIX: FULL REPOSITORY URL ---
# The previous "https://github.com" was causing the fatal error
REPO_URL="https://github.com/YashB-byte/aurora-shell-2.git"
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
