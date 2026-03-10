# --- AURORA SYSTEM INSTALLER v4.4.7 (PowerShell) ---
# Optimization: Dynamic Centering & Secure Credential Handling

# 0. CHECK POWERSHELL VERSION
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "❌ PowerShell 7+ required. Installing..." -ForegroundColor Red
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Microsoft.PowerShell
        Write-Host "✅ PowerShell 7 installed. Please restart and run this again." -ForegroundColor Green
        exit
    } else {
        Write-Host "❌ Please install PowerShell 7 manually: https://aka.ms/powershell" -ForegroundColor Red
        exit 1
    }
}

$InstallPath = Join-Path $HOME ".aurora-shell_2theme"

# 1. PASSWORD SETUP
if ($env:PRESERVED_PASSWORD) {
    Write-Host "🔄 Preserving existing password..." -ForegroundColor Cyan
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
        Write-Host "❌ Passwords do not match. Installation aborted." -ForegroundColor Red
        exit 1
    }
}

# 2. FILE SETUP (PURGE & CLONE)
if (Test-Path $InstallPath) {
    Write-Host "🧹 Purging old Aurora files..." -ForegroundColor Yellow
    Remove-Item -Path $InstallPath -Recurse -Force
}
New-Item -Path $InstallPath -ItemType Directory | Out-Null

Write-Host "📥 Cloning Aurora Shell..." -ForegroundColor Cyan
$RepoPath = Join-Path $InstallPath "repo"
git clone --progress https://github.com/YashB-byte/aurora-shell-2.git $RepoPath

# 3. GENERATE THEME FILE
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
            $Attempts++
            Write-Host "❌ Incorrect. $((3-$Attempts)) left." -ForegroundColor Yellow
            if ($Attempts -eq 3) { exit }
        }
    }
}

function Show-AuroraDisplay {
    # System Stats
    $Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue).EstimatedChargeRemaining
    $BatteryStr = if (-not $Battery) { "AC" } else { "$Battery%" }
    $Cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 2)
    $Disk = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
    $DateStr = (Get-Date).ToShortDateString()

    # Dynamic Centering Logic
    $WindowWidth = $Host.UI.RawUI.WindowSize.Width
    $StatsLine = "📅 $DateStr | 🔋 $BatteryStr | 🧠 CPU: $Cpu% | 💽 ${Disk}GB Free"
    $Separator = "------------------------------------------------------------"
    
    $StatsPadding = [math]::Max(0, [int](($WindowWidth - $StatsLine.Length) / 2))
    $SepPadding = [math]::Max(0, [int](($WindowWidth - $Separator.Length) / 2))

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
    Write-Host (" " * $SepPadding + $Separator) -ForegroundColor Cyan
    Write-Host ""
}

# STARTUP
Clear-Host
Show-AuroraLock
Show-AuroraDisplay
'@

# Inject password and save
$ThemeScript.Replace('PASSWORD_PLACEHOLDER', $PlainPass) | Out-File -FilePath $ThemeFile -Encoding utf8

# 4. LINK TO PROFILE
if (-not (Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force | Out-Null }
$ProfileContent = Get-Content $PROFILE
if ($ProfileContent -notmatch "aurora_theme.ps1") {
    Add-Content -Path $PROFILE -Value "`n. `"$ThemeFile`""
}

Write-Host "✨ Aurora v4.4.7 (Windows Edition) installed!" -ForegroundColor Green
Write-Host "🔄 Restart terminal to activate." -ForegroundColor Cyan
