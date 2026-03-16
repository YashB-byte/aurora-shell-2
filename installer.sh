#!/bin/bash
# --- AURORA-SHELL USER-SPECIFIC INSTALLER ---
INSTALL_DIR="$HOME/.aurora-shell"

echo "🌈 Preparing Aurora-Shell for current user..."
mkdir -p "$INSTALL_DIR"

if [ -f "./aurora_theme.sh" ]; then
    cp "./aurora_theme.sh" "$INSTALL_DIR/aurora_theme.sh"
    chmod +x "$INSTALL_DIR/aurora_theme.sh"
    echo "✅ Theme file placed in $INSTALL_DIR"
else
    echo "❌ Error: aurora_theme.sh missing."
    exit 1
fi

echo "✨ Done! Add 'source ~/.aurora-shell/aurora_theme.sh' to your .zshrc"