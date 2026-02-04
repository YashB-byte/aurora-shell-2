$ProfilePath = $PROFILE
$ProfileDir = Split-Path -Parent $ProfilePath

if (!(Test-Path -Path $ProfileDir)) { New-Item -ItemType Directory -Path $ProfileDir -Force }

$AuroraCode = @"
# Force older PowerShell to handle UTF8
if (`$PSVersionTable.PSVersion.Major -le 5) {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}

function Get-AuroraStats {
    `$date = Get-Date -Format "MM/dd/yy"
    try {
        `$batt = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
        `$battStr = if (`$batt) { "`$batt%" } else { "AC" }
    } catch { `$battStr = "AC" }
    
    `$disk = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    `$cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 1)
    if (!`$cpu) { `$cpu = "0" }

    Write-Host ""
    Write-Host " [ AURORA SHELL ACTIVE ] " -ForegroundColor Cyan
    # Using a safer way to print that won't trigger 'Command Not Found' errors
    `$statusLine = " 📅 `$date | 🔋 `$battStr | 🧠 CPU: `$cpu% | 💽 `$disk Gi Free"
    Write-Host `$statusLine -ForegroundColor Magenta
    Write-Host " ------------------------------------------------------------"
}

Get-AuroraStats

function prompt {
    Write-Host " aurora " -ForegroundColor Cyan -NoNewline
    Write-Host "`$env:USERNAME@`$env:COMPUTERNAME: " -ForegroundColor White -NoNewline
    return "> "
}
"@

# Save with UTF8 with BOM (Best for older Windows PowerShell compatibility)
[System.IO.File]::WriteAllLines($ProfilePath, $AuroraCode)
Write-Host "✨ Universal build successful! Restart PowerShell." -ForegroundColor Green