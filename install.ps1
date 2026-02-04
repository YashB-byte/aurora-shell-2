$ProfilePath = $PROFILE
$AuroraCode = @"
function Get-AuroraStats {
    `$date = Get-Date -Format "MM/dd/yy"
    `$batt = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
    if (!`$batt) { `$batt = "AC" } else { `$batt = "`$batt%" }
    `$disk = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    `$cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 1)

    Write-Host ""
    Write-Host " 🌌 AURORA SHELL ACTIVE (WINDOWS)" -ForegroundColor Cyan
    # Fixed: Wrapped the line in quotes so PowerShell doesn't try to 'run' it
    Write-Host " 📅 `$date | 🔋 `$batt | 🧠 CPU: `$cpu% | 💽 `$(`$disk)Gi Free" -ForegroundColor Magenta
    Write-Host " ------------------------------------------------------------"
}

Get-AuroraStats

function prompt {
    # Simpler emojis for better Windows compatibility
    Write-Host " aurora " -ForegroundColor Cyan -NoNewline
    Write-Host "`$(`$env:USERNAME)@`$(`$env:COMPUTERNAME): " -ForegroundColor White -NoNewline
    return "> "
}
"@

Set-Content -Path $ProfilePath -Value $AuroraCode -Encoding utf8
Write-Host "✨ Clean build successful! Restart PowerShell." -ForegroundColor Green