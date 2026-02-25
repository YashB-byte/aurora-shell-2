#!/bin/bash
set -e

# 1. SET YOUR PASSWORD HERE
CORRECT_PASSWORD=user_input

# Check if we are running in a Terminal or a Script (Bypass for GitHub Actions)
if [[ -t 0 || -p /dev/stdin ]]; then
    echo -e "\033[0;35m🔐 Aurora Security Check\033[0m"
    # Use /dev/tty to ensure the prompt works with curl pipes
    read -rsp "Enter Deployment Password: " user_input </dev/tty
    echo "" 
    
    # Trim whitespace
    user_input=$(echo "$user_input" | xargs)
    
    if [ "$user_input" != "$CORRECT_PASSWORD" ]; then
        echo -e "\033[0;31m❌ Access Denied.\033[0m"
        exit 1
    fi
else
    echo "🤖 Automated environment detected. Skipping password check."
fi

# --- CONFIGURATION ---
REPO_URL="https://github.com/YashB-byte/aurora-shell-2.git"
INSTALL_PATH="$HOME/.aurora-shell_2theme"
TEMP_PATH="/tmp/aurora-tmp"

# --- CLEAN AND CLONE ---
rm -rf "$TEMP_PATH"
echo "📥 Fetching latest files from GitHub..."
git clone "$REPO_URL" "$TEMP_PATH"

mkdir -p "$INSTALL_PATH"
cp -rf "$TEMP_PATH"/* "$INSTALL_PATH/"
rm -rf "$TEMP_PATH"

echo "🎨 Writing Theme, Stats Bar, and Block Art..."

# --- GENERATE THE THEME FILE ---
cat << 'EOF' > "$INSTALL_PATH/aurora_theme.sh"
# Function to calculate and display system stats
aurora_stats() {
    local date_val=$(date +"%m/%d/%y")
    # Battery check for macOS
    local battery=$(pmset -g batt 2>/dev/null | grep -Eo "\d+%" | head -1 || echo "N/A")
    # CPU Load (Example for macOS)
    local cpu_load=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    # Disk space available in Gi
    local disk_free=$(df -h / | awk 'NR==2 {print $4}')

    echo -e "\033[0;36m📅 $date_val | 🔋 $battery | 🧠 CPU: $cpu_load | 💽 $disk_free Free\033[0m"
    echo "---------------------------------------------------"
}

# The ASCII Logo
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

# Hook the stats bar to run before every prompt
precmd() { aurora_stats }

# Set the Prompt
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

# --- UPDATE ZSHRC ---
ZSH_CONFIG="$HOME/.zshrc"
if ! grep -q "source $INSTALL_PATH/aurora_theme.sh" "$ZSH_CONFIG"; then
    echo "source $INSTALL_PATH/aurora_theme.sh" >> "$ZSH_CONFIG"
fi

echo -e "\033[0;32m✨ Success! Aurora Shell is deployed.\033[0m"
echo "Please run: source ~/.zshrc"
