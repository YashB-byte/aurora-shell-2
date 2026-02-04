# Get the profile path
$ProfilePath = $PROFILE
$ProfileDir = Split-Path -Parent $ProfilePath

# 1. FORCE the directory to exist (Fixes the red error in image_fe7da3)
if (!(Test-Path -Path $ProfileDir)) { 
    New-Item -ItemType Directory -Path $ProfileDir -Force 
}

$AuroraCode = @"
# Force UTF8 for Emojis
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-AuroraStats {
    `$date = Get-Date -Format "MM/dd/yy"
    `$batt = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
    if (!`$batt) { `$batt = "AC" } else { `$batt = "`$batt%" }
    `$disk = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    `$cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 1)

    Write-Host ""
    Write-Host " 🌌 AURORA SHELL ACTIVE (WINDOWS)" -ForegroundColor Cyan
    # FIXED: Using Write-Host stops PowerShell from 'executing' the line
    Write-Host " 📅 `$date | 🔋 `$batt | 🧠 CPU: `$cpu% | 💽 `$(`$disk)Gi Free" -ForegroundColor Magenta
    Write-Host " ------------------------------------------------------------"
}

Get-AuroraStats

function prompt {
    Write-Host " aurora " -ForegroundColor Cyan -NoNewline
    Write-Host "`$(`$env:USERNAME)@`$(`$env:COMPUTERNAME): " -ForegroundColor White -NoNewline
    return "> "
}
"@

# 2. Save with UTF8 to fix those weird 'ðŸ' characters
Set-Content -Path $ProfilePath -Value $AuroraCode -Encoding utf8
Write-Host "✨ Final build successful! Restart PowerShell." -ForegroundColor Green