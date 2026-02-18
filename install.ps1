# Get the modern PowerShell profile path
$ProfilePath = $PROFILE
$ProfileDir = Split-Path -Parent $ProfilePath

# Force create the directory if it's missing (fixes the 'path not found' error)
if (!(Test-Path -Path $ProfileDir)) { 
    New-Item -ItemType Directory -Path $ProfileDir -Force 
}

$AuroraCode = @"
# Enable modern UTF8 encoding for Emojis
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Capture the exact time this terminal session started
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
    Write-Host "
 █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ 
██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗
███████║██║   ██║██████╔╝██║   ██║██████╔╝███████║
██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██║
██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
                                                  
███████╗██╗  ██╗███████╗██╗     ██╗               
██╔════╝██║  ██║██╔════╝██║     ██║               
███████╗███████║█████╗  ██║     ██║               
╚════██║██╔══██║██╔══╝  ██║     ██║               
███████║██║  ██║███████╗███████╗███████╗          
╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝          
" -ForegroundColor Green
    # The New Status Line with Session Start Time
    Write-Host " 📅 `$date | 🕒 Start: `$sessionStart | 🔋 `$battStr | 🧠 CPU: `$cpu%" -ForegroundColor Magenta
    Write-Host " 💽 `$disk Gi Free" -ForegroundColor Magenta
    Write-Host " ------------------------------------------------------------"
}

# Run once on startup
Get-AuroraStats

function prompt {
    Write-Host " 🌌aurora " -ForegroundColor Cyan -NoNewline
    Write-Host "`$(`$env:USERNAME)@`$(`$env:COMPUTERNAME): " -ForegroundColor White -NoNewline
    return "> "
}
"@

# Save with UTF8 encoding for those high-def icons
Set-Content -Path $ProfilePath -Value $AuroraCode -Encoding utf8

Write-Host "✨ SUCCESS: Aurora Shell (Modern Edition) Installed!" -ForegroundColor Green
