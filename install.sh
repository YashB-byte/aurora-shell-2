#!/bin/bash
set -e # Exit if any command fails

echo -e "\033[0;36m🌌 Starting Aurora Shell Deployment...\033[0m"

# 1. Pull the latest repo (The Lazy Shortcut)
REPO_URL="https://github.com/YashB-byte/aurora-shell-2.git"
INSTALL_PATH="$HOME/.aurora-shell"
TEMP_PATH="/tmp/aurora-tmp"

rm -rf "$TEMP_PATH"
echo "📥 Fetching latest files from GitHub..."
git clone "$REPO_URL" "$TEMP_PATH"

# 2. Setup directory
mkdir -p "$INSTALL_PATH"
cp -rf "$TEMP_PATH"/* "$INSTALL_PATH/"
rm -rf "$TEMP_PATH"

# 3. Create the Theme File (The Logic you provided)
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
        pmset -g batt | grep -Eo "\d+%" | head -1
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
grep -q "source $INSTALL_PATH/aurora_theme.sh" "$ZSH_CONFIG" || echo "source $INSTALL_PATH/aurora_theme.sh" >> "$ZSH_CONFIG"

echo -e "\033[0;32m✨ Success! Aurora Shell is deployed.\033[0m"
echo "👉 Run 'source ~/.zshrc' or restart your terminal to see the magic."
