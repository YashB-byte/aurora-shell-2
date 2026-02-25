#!/bin/bash

echo "🌌 Uninstalling Aurora Shell..."

# Remove theme file
if [ -f "$HOME/.aurora-shell/aurora_theme.sh" ]; then
    rm "$HOME/.aurora-shell/aurora_theme.sh"
    echo "✓ Removed ~/.aurora_theme.sh"
fi

# Remove from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    sed -i.bak '/source ~/.aurora_theme.sh/d' "$HOME/.zshrc"
    echo "✓ Removed Aurora Shell from ~/.zshrc"
fi

echo "✅ Aurora Shell uninstalled! Restart your terminal."
