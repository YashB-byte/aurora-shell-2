$ProfilePath = $PROFILE

$AuroraCode = @"
# Set output encoding to handle emojis correctly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-AuroraStats {
    `$date = Get-Date -Format "MM/dd/yy"
    `$batt = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
    if (!`$batt) { `$batt = "AC" } else { `$batt = "`$batt%" }
    `$disk = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    `$cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 1)

    Write-Host ""
    Write-Host " 🌌 AURORA SHELL ACTIVE (WINDOWS)" -ForegroundColor Cyan
    # FIXED: Wrapped in double quotes and added -ForegroundColor to ensure it prints as text
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

# Save with UTF8 encoding specifically for Windows
Set-Content -Path $ProfilePath -Value $AuroraCode -Encoding utf8
Write-Host "✨ Clean build successful! Restart PowerShell." -ForegroundColor Green