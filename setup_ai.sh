#!/bin/bash

# 1. Install Ollama if missing
if ! command -v ollama &> /dev/null; then
    echo "🌌 Aurora: Ollama not found. Installing..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "✅ Aurora: Ollama Agent detected."
fi

# 2. Start Ollama in the background
if ! pgrep -x "ollama" > /dev/null; then
    echo "🚀 Starting Ollama background service..."
    nohup ollama serve > /dev/null 2>&1 &
    sleep 5
fi

# 3. Pull the "Brain" (Model)
echo "🧠 Pulling Llama3 model (A2A)..."
ollama pull llama3

echo "✨ Aurora: AI Setup Complete!"
