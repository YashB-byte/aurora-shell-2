#!/bin/bash
echo "🌌 Aurora Shell: Installing the Final Optimization..."

# 1. Ensure lolcat is available
if ! command -v lolcat &> /dev/null; then
    echo "🌈 Installing rainbow support..."
    brew install lolcat &>/dev/null || sudo apt-get install lolcat -y &>/dev/null
fi

# 2. Create the standalone theme file
cat << 'EOF' > ~/.aurora_theme.sh
get_battery() { 
    if [[ "$OSTYPE" == "darwin"* ]]; then pmset -g batt | grep -Eo "\d+%" | head -1; else echo "100%"; fi 
}
get_disk() { df -h / | awk 'NR==2 {print $4}'; }

echo "AURORA SHELL PRO ACTIVE" | lolcat
echo "📅 $(date +'%D') | 🔋 $(get_battery) | 💽 $(get_disk) Free"
export PROMPT="%F{cyan}🌌 Aurora %F{white}%n@%m: %f"
EOF

# 3. Link it to .zshrc cleanly
grep -q "source ~/.aurora_theme.sh" ~/.zshrc || echo "source ~/.aurora_theme.sh" >> ~/.zshrc

echo "✨ Theme optimized! Restart your terminal to see the Aurora."