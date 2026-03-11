# --- AURORA SYSTEM INSTALLER v4.5.0 ---
# Logic: Force Winget Install | Automated Dependencies | Multi-Profile Sourcing | Centered ASCII

# 0. INSTALL WINGET IF MISSING
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Winget missing. Installing App Installer (Winget)..." -ForegroundColor Yellow
    $WingetPath = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile $WingetPath
    Add-AppxPackage -Path $WingetPath
    Write-Host "✅ Winget installed. Refreshing environment..." -ForegroundColor Green
}

# 1. PRE-FLIGHT: POWERSHELL & GIT CHECK
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "❌ PowerShell 7+ required. Upgrading via Winget..." -ForegroundColor Yellow
    winget install Microsoft.PowerShell --silent --accept-source-agreements
    Write-Host "✅ Restart terminal and run this installer again." -ForegroundColor Green
    exit
}

Write-Host "🔍 Verifying Git..." -ForegroundColor Gray
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Git missing. Invoking Winget..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget --silent --accept-source-agreements --accept-package-agreements
    
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Winget install failed. Downloading Git directly..." -ForegroundColor Yellow
        $gitPath = "$env:TEMP\Git-Installer.exe"
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -OutFile $gitPath
        Start-Process $gitPath -ArgumentList "/VERYSILENT /NORESTART" -Wait
    }
}

$InstallPath = Join-Path $HOME ".aurora-shell_2theme"

# 2. CREDENTIALS
if ($env:PRESERVED_PASSWORD) {
    $PlainPass = $env:PRESERVED_PASSWORD
} else {
    Write-Host "🌌 Aurora Setup: Set your Terminal Lock Password" -ForegroundColor Magenta
    $NewPass = Read-Host -AsSecureString "Set new Terminal Password"
    $ConfirmPass = Read-Host -AsSecureString "Confirm Password"

    $BSTR1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPass)
    $PlainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR1)
    $BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConfirmPass)
    $PlainConfirm = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)

    if ($PlainPass -ne $PlainConfirm) {
        Write-Host "❌ Passwords do not match!" -ForegroundColor Red
        exit 1
    }
}

# 3. PURGE & CLONE
if (Test-Path $InstallPath) {
    Write-Host "🧹 Purging old Aurora build..." -ForegroundColor Yellow
    Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $InstallPath -ItemType Directory | Out-Null

Write-Host "📥 Cloning Aurora Shell v4.5.0..." -ForegroundColor Cyan
$RepoPath = Join-Path $InstallPath "repo"
git clone --progress https://github.com/YashB-byte/aurora-shell-2.git $RepoPath

# 4. GENERATE THEME ENGINE
$ThemeFile = Join-Path $InstallPath "aurora_theme.ps1"
$ThemeScript = @'
$CORRECT_PASSWORD = "PASSWORD_PLACEHOLDER"

function Show-AuroraLock {
    Write-Host "🔐 Aurora Terminal Lock" -ForegroundColor Magenta
    $Attempts = 0
    while ($Attempts -lt 3) {
        $ui = Read-Host -AsSecureString "Password"
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ui)
        $InputPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        if ($InputPass -eq $CORRECT_PASSWORD) {
            Write-Host "✅ Access Granted." -ForegroundColor Green
            return
        } else {
            $Attempts++; Write-Host "❌ Incorrect. $((3-$Attempts)) left." -ForegroundColor Yellow
            if ($Attempts -eq 3) { exit }
        }
    }
}

function Show-AuroraDisplay {
    $Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue).EstimatedChargeRemaining
    $BatteryStr = if (-not $Battery) { "AC" } else { "$Battery%" }
    $Cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 2)
    $Disk = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
    $WindowWidth = $Host.UI.RawUI.WindowSize.Width
    $StatsLine = "📅 $(Get-Date -Format 'MM/dd/yy') | 🔋 $BatteryStr | 🧠 CPU: $Cpu% | 💽 ${Disk}GB Free"
    $StatsPadding = [math]::Max(0, [int](($WindowWidth - $StatsLine.Length) / 2))
    
    $Ascii = @"
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
"@
    Write-Host $Ascii -ForegroundColor Cyan
    Write-Host (" " * $StatsPadding + $StatsLine) -ForegroundColor Cyan
}

Clear-Host
Show-AuroraLock
Show-AuroraDisplay
'@

$ThemeScript.Replace('PASSWORD_PLACEHOLDER', $PlainPass) | Out-File -FilePath $ThemeFile -Encoding utf8

# 5. MULTI-PROFILE SOURCING
$ProfilePaths = @($PROFILE.CurrentUserCurrentHost, $PROFILE.CurrentUserAllHosts)
foreach ($P in $ProfilePaths) {
    if ($P) {
        $PDir = Split-Path $P
        if (-not (Test-Path $PDir)) { New-Item -Path $PDir -ItemType Directory -Force | Out-Null }
        if (-not (Test-Path $P)) { New-Item -Path $P -ItemType File -Force | Out-Null }
        
        $Content = Get-Content $P -ErrorAction SilentlyContinue
        if ($Content -notmatch "aurora_theme.ps1") {
            Add-Content -Path $P -Value "`n. `"$ThemeFile`""
        }
    }
}

# 6. FINAL PERMISSIONS
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Host "✨ Aurora v4.5.0 Installed!" -ForegroundColor Green
Write-Host "🔄 Restart terminal to activate." -ForegroundColor Cyan
