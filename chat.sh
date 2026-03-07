#!/bin/bash
clear
echo -e "\033[1;34m🌌 Aurora Chat Mode Activated (Local Llama3)\033[0m"
echo -e "\033[0;90mType 'exit' to quit or '/reset' to clear memory.\033[0m"
echo "-----------------------------------------------"

while true; do
    echo -n "👤 You: "
    read user_input
    
    if [[ "$user_input" == "exit" || "$user_input" == "quit" ]]; then
        echo "👋 Goodbye!"
        break
    fi

    # This calls your JS file and stays inside the loop
    node ~/aurora-shell-2/auseaia.js "$user_input"
done
