#!/bin/bash

# 1. Define a log file for user troubleshooting
LOG_FILE="$HOME/aurora_install.log"

echo "Starting Aurora-Shell Installation..." > "$LOG_FILE"

# 2. Execute the remote install script
# We use the exact command you provided to ensure consistency
/bin/bash <(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh) >> "$LOG_FILE" 2>&1

# 3. Verify success
if [ $? -eq 0 ]; then
    echo "Installation completed successfully." >> "$LOG_FILE"
else
    echo "Installation failed. Check the log for details." >> "$LOG_FILE"
    exit 1
fi

exit 0