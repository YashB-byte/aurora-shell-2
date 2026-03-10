# --- AURORA UNINSTALLER v4.4.7 (PowerShell) ---

$InstallPath = Join-Path $HOME ".aurora-shell_2theme"

Write-Host "⚠️ Uninstalling Aurora Shell..." -ForegroundColor Yellow

# 1. Remove Files
if (Test-Path $InstallPath) {
    Remove-Item -Path $InstallPath -Recurse -Force
    Write-Host "✅ Removed Aurora system files." -ForegroundColor Green
}

# 2. Clean Profile
if (Test-Path $PROFILE) {
    $OldContent = Get-Content $PROFILE
    # Filter out any line mentioning the aurora theme
    $NewContent = $OldContent | Where-Object { $_ -notmatch "aurora_theme.ps1" }
    
    $NewContent | Set-Content $PROFILE
    Write-Host "✅ Cleaned PowerShell Profile." -ForegroundColor Green
}

Write-Host "✨ Aurora has been successfully removed." -ForegroundColor Cyan
