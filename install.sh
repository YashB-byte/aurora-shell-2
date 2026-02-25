#!/bin/bash
set -e # Exit if any command fails

# --- PASSWORD CONFIGURATION ---
CORRECT_PASSWORD="your_secure_password_here"

echo -e "\033[0;35m🔐 Aurora Security Check\033[0m"
# ADDING </dev/tty allows it to work when piped from curl
read -sp "Enter Deployment Password: " user_input </dev/tty
echo "" 

if [ "$user_input" != "$CORRECT_PASSWORD" ]; then
    echo -e "\033[0;31m❌ Access Denied: Incorrect Password.\033[0m"
    exit 1
fi
# ------------------------------


echo -e "\033[0;36m🌌 Starting Aurora Shell Deployment...\033[0m"

# 1. Pull the latest repo
REPO_URL="https://github.com"
INSTALL_PATH="$HOME/.aurora-shell_2theme"
TEMP_PATH="/tmp/aurora-tmp"

rm -rf "$TEMP_PATH"
echo "📥 Fetching latest files from GitHub..."
git clone "$REPO_URL" "$TEMP_PATH"

# 2. Setup directory
mkdir -p "$INSTALL_PATH"
cp -rf "$TEMP_PATH"/* "$INSTALL_PATH/"
rm -rf "$TEMP_PATH"

# 3. Create the Theme File
echo "🎨 Writing Theme and Block Art..."
cat << 'EOF' > "$INSTALL_PATH/aurora_theme.sh"
# Aurora Shell Official Banner
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

get_battery() { 
    if command -v pmset &> /dev/null; then 
        pmset -g batt | grep -Eo "[0-9]+%" | head -1
    else 
        echo "⚡ AC" 
    fi
}
get_disk() { df -h / | awk 'NR==2 {print $4}'; }
get_cpu() { uptime | awk -F'load averages: ' '{ print $2 }' | cut -d' ' -f1; }

echo "📅 $(date +'%D') | 🔋 $(get_battery) | 🧠 CPU: $(get_cpu) | 💽 $(get_disk) Free" | lolcat
echo "---------------------------------------------------" | lolcat
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

# 4. Link it to .zshrc
ZSH_CONFIG="$HOME/.zshrc"
# Only add the source line if it's not already there
if ! grep -q "source $INSTALL_PATH/aurora_theme.sh" "$ZSH_CONFIG"; then
    echo "source $INSTALL_PATH/aurora_theme.sh" >> "$ZSH_CONFIG"
fi

echo -e "\033[0;32m✨ Success! Aurora Shell is deployed.\033[0m"
echo "👉 Run 'source ~/.zshrc' or restart your terminal to see the magic."
