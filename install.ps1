# Pure PowerShell script for Windows
$ProfilePath = $PROFILE
if (!(Test-Path -Path $ProfilePath)) { 
    New-Item -ItemType File -Path $ProfilePath -Force 
}

$AuroraCode = @"
function Get-AuroraStats {
    `$date = Get-Date -Format "MM/dd/yy"
    # Windows-specific Hardware calls
    `$batt = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
    if (!`$batt) { `$batt = "AC" } else { `$batt = "`$batt%" }
    `$disk = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    `$cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 1)

    Write-Host ""
    Write-Host " 🌌 AURORA SHELL ACTIVE (WINDOWS)" -ForegroundColor Cyan
    Write-Host " 📅 `$date | 🔋 `$batt | 🧠 CPU: `$cpu% | 💽 `$(`$disk)Gi Free" -ForegroundColor Magenta
    Write-Host " ------------------------------------------------------------"
}

Get-AuroraStats

function prompt {
    Write-Host "🌌 Aurora " -ForegroundColor Cyan -NoNewline
    Write-Host "`$(`$env:USERNAME)@`$(`$env:COMPUTERNAME): " -ForegroundColor White -NoNewline
    return "> "
}
"@

Set-Content -Path $ProfilePath -Value $AuroraCode
Write-Host "✨ Success! Windows profile updated. Restart PowerShell." -ForegroundColor Green