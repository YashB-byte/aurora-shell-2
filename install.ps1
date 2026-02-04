# Get the modern PowerShell profile path
$ProfilePath = $PROFILE
$ProfileDir = Split-Path -Parent $ProfilePath

# 1. Force the folder to exist (Prevents the 'Path not found' error)
if (!(Test-Path -Path $ProfileDir)) { 
    New-Item -ItemType Directory -Path $ProfileDir -Force 
}

# 2. Define the Profile Script
$AuroraCode = @"
# Force UTF8 for clear Emoji rendering
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Capture session start time immediately
`$sessionStart = Get-Date -Format "HH:mm:ss"

function Get-AuroraStats {
    `$date = Get-Date -Format "MM/dd/yy"
    
    # Battery Check
    try {
        `$batt = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
        `$battStr = if (`$batt) { "`$batt%" } else { "AC" }
    } catch { `$battStr = "AC" }

    # Disk and CPU Stats
    `$disk = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    `$cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 1)
    if (!`$cpu) { `$cpu = "0" }

    Write-Host ""
    Write-Host " 🌌 AURORA SHELL ACTIVE (WINDOWS)" -ForegroundColor Cyan
    # Displaying the Date and the new Session Start Time
    Write-Host " 📅 `$date | 🕒 Start: `$sessionStart | 🔋 `$battStr | 🧠 CPU: `$cpu%" -ForegroundColor Magenta
    Write-Host " 💽 `$disk Gi Free" -ForegroundColor Magenta
    Write-Host " ------------------------------------------------------------"
}

# Run diagnostics at startup
Get-AuroraStats

# Custom Prompt
function prompt {
    Write-Host " aurora " -ForegroundColor Cyan -NoNewline
    Write-Host "`$(`$env:USERNAME)@`$(`$env:COMPUTERNAME): " -ForegroundColor White -NoNewline
    return "> "
}
"@

# 3. Save to profile with UTF8 encoding
Set-Content -Path $ProfilePath -Value $AuroraCode -Encoding utf8

Write-Host ""
Write-Host "✨ SUCCESS: Aurora Shell updated with Session Start time!" -ForegroundColor Green
Write-Host "🚀 Restart PowerShell Preview to see the changes." -ForegroundColor Green