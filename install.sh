#!/bin/bash
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
