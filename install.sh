#!/bin/bash
echo "🌌 Installing Aurora Shell Pro..."

# Install lolcat for rainbow effects if missing
if ! command -v lolcat &> /dev/null; then
    echo "🌈 Adding rainbow support..."
    brew install lolcat 2>/dev/null || sudo apt-get install lolcat -y 2>/dev/null
fi

# Add the high-tech prompt to .zshrc
cat << 'EOF' > ~/.aurora_theme.sh
get_battery() { pmset -g batt | grep -Eo "\d+%" | head -1 || echo "100%"; }
get_disk() { df -h / | awk 'NR==2 {print $4}'; }

echo "AURORA SHELL ACTIVE" | lolcat
echo "📅 $(date +'%D') | 🔋 $(get_battery) | 💽 $(get_disk) Free"
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

# Ensure .zshrc loads the theme
grep -q "source ~/.aurora_theme.sh" ~/.zshrc || echo "source ~/.aurora_theme.sh" >> ~/.zshrc

echo "✨ Success! Restart your terminal to see the rainbow."#!/bin/bash
# Aurora Shell - Official Installer

echo "🌌 Installing Aurora Shell..."

# Create config directory
mkdir -p ~/.aurora

# Add the theme to .zshrc ONLY if it's not already there
if ! grep -q "Aurora Shell Theme" ~/.zshrc; then
cat << 'EOF' >> ~/.zshrc

# --- Aurora Shell Theme ---
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF
fi

echo "✨ Aurora Shell installed successfully!"
echo "🔄 Run 'source ~/.zshrc' to refresh your terminal."#!/bin/bash
echo "🌌 Installing Aurora Shell..."

# 1. Create the local config folder
mkdir -p ~/.aurora

# 2. Add the theme logic to .zshrc
# This adds your cool prompt and rainbow colors
cat << 'EOF' >> ~/.zshrc

# --- Aurora Shell Theme ---
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
# Add your battery and disk space logic below
EOF

echo "✨ Aurora Shell installed successfully!"
echo "🔄 Run 'source ~/.zshrc' to see the changes."# Create the directory
mkdir -p ~/aurora-shell-2
cd ~/aurora-shell-2

# Initialize git
git init
git remote add origin https://github.com/YashB-byte/aurora-shell-2.git

# Create the install script
nano install.sh
