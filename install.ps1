# --- AURORA SYSTEM INSTALLER v4.0.0 (PowerShell) ---

# 0. VERBOSE SETTINGS
$VerboseMode = $false
if ($args -contains "-v" -or $args -contains "--verbose") {
    $VerboseMode = $true
    Write-Host "🛠️ Verbose Mode Enabled" -ForegroundColor Yellow
}

# 1. SET PASSWORD
Write-Host "🌌 Aurora Setup: Set your Terminal Lock Password" -ForegroundColor Magenta
$NewPass = Read-Host -AsSecureString "Set new Terminal Password"
$ConfirmPass = Read-Host -AsSecureString "Confirm Password"

# Convert SecureString to plain text for comparison/storage
$BSTR1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPass)
$PlainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR1)

$BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConfirmPass)
$PlainConfirm = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)

if ($PlainPass -ne $PlainConfirm) {
    Write-Host "❌ Passwords do not match. Installation aborted." -ForegroundColor Red
    exit
}

# 2. DEPENDENCY CHECK
Write-Host "🔍 Checking for required tools..."
$Tools = @("git") # lolcat and pygmentize usually require WSL or specific Ruby/Python setups on Windows
foreach ($tool in $Tools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "📥 $tool not found. Please install $tool to continue." -ForegroundColor Red
        exit
    }
}

# 3. FILE SETUP
$InstallPath = Join-Path $HOME ".aurora-shell_2theme"
if (-not (Test-Path $InstallPath)) { New-Item -Path $InstallPath -ItemType Directory | Out-Null }

Write-Host "📥 Cloning Aurora Shell..."
$RepoPath = Join-Path $InstallPath "repo"
if (-not (Test-Path $RepoPath)) {
    git clone https://github.com/YashB-byte/aurora-shell-2.git $RepoPath
} else {
    Set-Location $RepoPath
    git pull
}

# 4. GENERATE THE THEME FILE
$ThemeFile = Join-Path $InstallPath "aurora_theme.ps1"
$ThemeContent = @"
`$CORRECT_PASSWORD = "$PlainPass"

function Show-AuroraLock {
    Write-Host "🔐 Aurora Terminal Lock" -ForegroundColor Magenta
    `$Attempts = 0
    while (`$Attempts -lt 3) {
        `$ui = Read-Host -AsSecureString "Password"
        `$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$ui)
        `$InputPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`$BSTR)
        
        if (`$InputPass -eq `$CORRECT_PASSWORD) {
            Write-Host "✅ Access Granted." -ForegroundColor Green
            return
        } else {
            `$Attempts++
            if (`$Attempts -lt 3) {
                Write-Host "❌ Incorrect. $((3-$Attempts)) left." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            } else {
                Write-Host "❌ Denied." -ForegroundColor Red
                exit
            }
        }
    }
}

function Show-AuroraDisplay {
    `$Battery = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining
    if (-not `$Battery) { `$Battery = "N/A" } else { `$Battery = "`$Battery%" }
    
    `$Ascii = @"
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
    Write-Host `$Ascii -ForegroundColor Cyan
    Write-Host "📅 $((Get-Date).ToShortDateString()) | 🔋 `$Battery | 🧠 CPU: $((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue.ToString('F2'))%" -ForegroundColor Cyan
    Write-Host "--------------------------------------" -ForegroundColor Cyan
}

function aurora {
    param(`$Option)
    switch (`$Option) {
        "lock" { Clear-Host; Show-AuroraLock; Show-AuroraDisplay }
        "pass" {
            `$op = Read-Host -AsSecureString "Current Pass"
            `$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$op)
            `$CurrentInput = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`$BSTR)
            
            if (`$CurrentInput -eq `$CORRECT_PASSWORD) {
                `$np = Read-Host -AsSecureString "New Pass"
                `$BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$np)
                `$NewInput = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`$BSTR2)
                # Note: Updating the file password via script in PS is complex; manually recommended or use Export-CliXml
                Write-Host "✅ Logic for password update triggered. Manual update of `$ThemeFile suggested for security." -ForegroundColor Green
            }
        }
        default {
            Write-Host "🌌 Aurora Command Center" -ForegroundColor Magenta
            Write-Host "🚀 [1] lock   : Re-engage terminal lock"
            Write-Host "🔑 [2] pass   : Change password"
            Write-Host "Usage: aurora lock | aurora pass"
        }
    }
}

Show-AuroraLock
Show-AuroraDisplay
"@

$ThemeContent | Out-File -FilePath $ThemeFile -Encoding utf8

# 5. LINK TO PROFILE
if (-not (Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force | Out-Null }
if (-not (Select-String -Path $PROFILE -Pattern "aurora_theme.ps1")) {
    Add-Content -Path $PROFILE -Value "`n. `"$ThemeFile`""
}

# 6. ACTIVATION
Write-Host "✨ Aurora shell installed successfully!" -ForegroundColor Green
$Activate = Read-Host "Would you like to activate it now? (y/n)"
if ($Activate -eq "y") {
    . $PROFILE
}

