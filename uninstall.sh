#!/bin/bash

echo "🌌 Uninstalling Aurora Shell..."

# 1. Define paths
AURORA_DIR="$HOME/.aurora-shell"
THEME_FILE="$AURORA_DIR/aurora_theme.sh"
ZSHRC="$HOME/.zshrc"

# 2. Remove the theme file if it exists
if [ -f "$THEME_FILE" ]; then
    rm "$THEME_FILE"
    echo "✓ Removed $THEME_FILE"
fi

# 3. Remove the directory if it exists
if [ -d "$AURORA_DIR" ]; then
    rm -rf "$AURORA_DIR"
    echo "✓ Removed $AURORA_DIR"
fi

# 4. Remove the line from .zshrc safely for both Mac and Linux
if [ -f "$ZSHRC" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version of sed
        sed -i '' '/aurora_theme.sh/d' "$ZSHRC"
    else
        # Linux version of sed
        sed -i '/aurora_theme.sh/d' "$ZSHRC"
    fi
    echo "✓ Removed Aurora Shell source line from $ZSHRC"
fi

echo "✅ Aurora Shell uninstalled! Restart your terminal or run: source ~/.zshrc"
