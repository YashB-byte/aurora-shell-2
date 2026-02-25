#!/bin/bash

echo "🌌 Uninstalling Aurora Shell..."

# 1. Remove the theme file and its directory if it's empty
if [ -f "$HOME/.aurora-shell/aurora_theme.sh" ]; then
    rm "$HOME/.aurora-shell/aurora_theme.sh"
    echo "✓ Removed ~/.aurora-shell/aurora_theme.sh"
fi

# Clean up the directory if it exists and is now empty
if [ -d "$HOME/.aurora-shell" ]; then
    rmdir "$HOME/.aurora-shell" 2>/dev/null
fi

# 2. Remove the line from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    # We use '|' as a delimiter so the slashes in the path don't break sed.
    # The -i '' syntax is specific to macOS to edit in-place without a backup.
    sed -i '' '\|source ~/.aurora-shell/aurora_theme.sh|d' "$HOME/.zshrc"
    echo "✓ Removed Aurora Shell from ~/.zshrc"
fi

echo "✅ Aurora Shell uninstalled! Restart your terminal."
