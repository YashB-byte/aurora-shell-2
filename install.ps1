# install.ps1 - Pure PowerShell Version
$ProfilePath = $PROFILE
if (!(Test-Path -Path $ProfilePath)) { New-Item -ItemType File -Path $ProfilePath -Force }

$AuroraCode = @"
function Get-AuroraStats {
    `$date = Get-Date -Format "MM/dd/yy"
    # Hardware calls for Windows
    `$batt = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
    if (!`$batt) { `$batt = "AC" } else { `$batt = "`$batt%" }
    `$disk = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    `$cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 1)

    Write-Host ""
    Write-Host " 🌌 AURORA SHELL ACTIVE (WINDOWS)" -ForegroundColor Cyan
    Write-Host " 📅 `$date | 🔋 `$batt | 🧠 CPU: `$cpu% | 💽 `$(`$disk)Gi Free" -ForegroundColor Magenta
    Write-Host " ------------------------------------------------------------"
}

# Run diagnostics at startup
Get-AuroraStats

# Custom Prompt Logic
function prompt {
    Write-Host "🌌 Aurora " -ForegroundColor Cyan -NoNewline
    Write-Host "`$(`$env:USERNAME)@`$(`$env:COMPUTERNAME): " -ForegroundColor White -NoNewline
    return "> "
}
"@

# Inject the code into your Windows Profile
Set-Content -Path $ProfilePath -Value $AuroraCode
Write-Host "✨ Success! Your Windows Aurora Profile is ready. Restart PowerShell." -ForegroundColor Green