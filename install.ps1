# install.ps1 - Complete Aurora Shell Installer for Windows
$ProfilePath = $PROFILE
$ProfileDir = Split-Path -Parent $ProfilePath

# 1. Ensure the PowerShell profile directory exists
if (!(Test-Path -Path $ProfileDir)) { 
    New-Item -ItemType Directory -Path $ProfileDir -Force 
}

# 2. Define the Profile Content
$AuroraCode = @"
# Force UTF8 for high-quality emoji rendering
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Capture the exact time the terminal was opened
`$sessionStart = Get-Date -Format "HH:mm:ss"

function Get-AuroraStats {
    `$date = Get-Date -Format "MM/dd/yy"
    
    # Hardware Diagnostics
    try {
        `$batt = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
        `$battStr = if (`$batt) { "`$batt%" } else { "AC" }
    } catch { `$battStr = "AC" }

    `$disk = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    
    # CPU Usage (Silent continue to avoid errors on some VM types)
    `$cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 1)
    if (!`$cpu) { `$cpu = "0" }

    # Greeting Display
    Write-Host ""
    Write-Host " 🌌 AURORA SHELL ACTIVE (WINDOWS)" -ForegroundColor Cyan
    Write-Host " 📅 `$date | 🕒 Start: `$sessionStart | 🔋 `$battStr | 🧠 CPU: `$cpu%" -ForegroundColor Magenta
    Write-Host " 💽 `$disk Gi Free" -ForegroundColor Magenta
    Write-Host " ------------------------------------------------------------"
}

# Run diagnostics immediately on startup
Get-AuroraStats

# Custom Prompt Logic
function prompt {
    Write-Host " aurora " -ForegroundColor Cyan -NoNewline
    Write-Host "`$(`$env:USERNAME)@`$(`$env:COMPUTERNAME): " -ForegroundColor White -NoNewline
    return "> "
}
"@

# 3. Save the file with UTF8 encoding
Set-Content -Path $ProfilePath -Value $AuroraCode -Encoding utf8

Write-Host ""
Write-Host "✨ SUCCESS: Aurora Shell has been installed to your profile." -ForegroundColor Green
Write-Host "🚀 RESTART PowerShell (or PowerShell Preview) to see the changes." -ForegroundColor Green