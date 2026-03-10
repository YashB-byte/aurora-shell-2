# --- AURORA SYSTEM INSTALLER v4.4.7 (PowerShell) ---

# 0. CHECK POWERSHELL VERSION
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "❌ PowerShell 7+ required. Installing..." -ForegroundColor Red
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Microsoft.PowerShell
        Write-Host "✅ PowerShell 7 installed. Please restart and run this installer again." -ForegroundColor Green
        exit
    } else {
        Write-Host "❌ winget not found. Please install PowerShell 7 manually: https://aka.ms/powershell" -ForegroundColor Red
        exit 1
    }
}

# 1. VERBOSE SETTINGS
$VerboseMode = $false
if ($args -contains "-v" -or $args -contains "--verbose") {
    $VerboseMode = $true
    Write-Host "🛠️ Verbose Mode Enabled" -ForegroundColor Yellow
}

$InstallPath = Join-Path $HOME ".aurora-shell_2theme"

# 2. SET PASSWORD
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

# 3. DEPENDENCY CHECK
Write-Host "🔍 Checking for required tools..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "📥 git not found. Installing..." -ForegroundColor Yellow
    winget install Git.Git
}

# 4. FILE SETUP (PURGE & CLONE)
if (Test-Path $InstallPath) {
    Write-Host "🧹 Purging old Aurora files..." -ForegroundColor Yellow
    Remove-Item -Path $InstallPath -Recurse -Force
}

New-Item -Path $InstallPath -ItemType Directory | Out-Null

Write-Host "📥 Cloning Aurora Shell..." -ForegroundColor Cyan
$RepoPath = Join-Path $InstallPath "repo"
git clone https://github.com/YashB-byte/aurora-shell-2.git $RepoPath

if (-not (Test-Path $RepoPath)) {
    Write-Host "❌ Git clone failed. Installation aborted." -ForegroundColor Red
    exit 1
}

# 5. GENERATE THEME FILE
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
                Write-Host "❌ Incorrect. `$((3-`$Attempts)) left." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            } else {
                Write-Host "❌ Denied." -ForegroundColor Red
                exit
            }
        }
    }
}

function Show-AuroraDisplay {
    `$Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue).EstimatedChargeRemaining
    if (-not `$Battery) { `$Battery = "AC" } else { `$Battery = "`$Battery%" }
    
    `$Cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 2)
    `$Disk = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
    
    Write-Host ' █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ ' -ForegroundColor Cyan
    Write-Host '██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗' -ForegroundColor Cyan
    Write-Host '███████║██║   ██║██████╔╝██║   ██║██████╔╝███████║' -ForegroundColor Cyan
    Write-Host '██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██║' -ForegroundColor Cyan
    Write-Host '██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║██║  ██║' -ForegroundColor Cyan
    Write-Host '╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝' -ForegroundColor Cyan
    Write-Host '' -ForegroundColor Cyan
    Write-Host '     ███████╗██╗  ██╗███████╗██╗     ██╗      ' -ForegroundColor Cyan
    Write-Host '     ██╔════╝██║  ██║██╔════╝██║     ██║      ' -ForegroundColor Cyan
    Write-Host '     ███████╗███████║█████╗  ██║     ██║      ' -ForegroundColor Cyan
    Write-Host '     ╚════██║██╔══██║██╔══╝  ██║     ██║      ' -ForegroundColor Cyan
    Write-Host '     ███████║██║  ██║███████╗███████╗███████╗ ' -ForegroundColor Cyan
    Write-Host '     ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝' -ForegroundColor Cyan
    Write-Host "📅 `$((Get-Date).ToShortDateString()) | 🔋 `$Battery | 🧠 CPU: `$Cpu% | 💽 `${Disk}GB Free" -ForegroundColor Cyan
    Write-Host "--------------------------------------" -ForegroundColor Cyan
}

function aurora {
    param([string]`$Command)
    
    switch (`$Command) {
        'lock' { 
            Clear-Host
            Show-AuroraLock
            Show-AuroraDisplay
        }
        'pass' {
            `$op = Read-Host -AsSecureString 'Current Pass'
            `$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$op)
            `$CurrentInput = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`$BSTR)
            
            if (`$CurrentInput -eq `$CORRECT_PASSWORD) {
                `$np = Read-Host -AsSecureString 'New Pass'
                `$BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$np)
                `$NewInput = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`$BSTR2)
                
                (Get-Content '$InstallPath\aurora_theme.ps1') -replace 'CORRECT_PASSWORD = \".*\"', \"CORRECT_PASSWORD = \`\"`$NewInput\`\"\" | Set-Content '$InstallPath\aurora_theme.ps1'
                `$global:CORRECT_PASSWORD = `$NewInput
                Write-Host '✅ Password updated!' -ForegroundColor Green
            } else {
                Write-Host '❌ Wrong password.' -ForegroundColor Red
            }
        }
        'update' {
            `$verify = Read-Host -AsSecureString 'Enter password to update'
            `$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$verify)
            `$VerifyInput = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`$BSTR)
            
            if (`$VerifyInput -ne `$CORRECT_PASSWORD) {
                Write-Host '❌ Incorrect password. Update cancelled.' -ForegroundColor Red
                return
            }
            
            Write-Host '🔄 Updating Aurora Shell from main branch...' -ForegroundColor Magenta
            `$TempInstaller = [System.IO.Path]::GetTempFileName() + '.ps1'
            Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.ps1' -OutFile `$TempInstaller
            `$env:PRESERVED_PASSWORD = `$CORRECT_PASSWORD
            & `$TempInstaller
            Remove-Item `$TempInstaller
        }
        default {
            Write-Host '🌌 Aurora Command Center' -ForegroundColor Magenta
            Write-Host '---------------------------------------'
            Write-Host '🚀 [1] lock   : Re-engage terminal lock'
            Write-Host '🔑 [2] pass   : Change password'
            Write-Host '🔄 [3] update : Update Aurora Shell'
            Write-Host ''
            Write-Host 'Usage: aurora lock | aurora pass | aurora update'
        }
    }
}

Show-AuroraLock
Show-AuroraDisplay
"@

$ThemeContent | Out-File -FilePath $ThemeFile -Encoding utf8

# 6. LINK TO PROFILE
if (-not (Test-Path $PROFILE)) { 
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null 
}

if (-not (Select-String -Path $PROFILE -Pattern "aurora_theme.ps1" -Quiet)) {
    Add-Content -Path $PROFILE -Value "`n. `"$ThemeFile`""
}

# 7. SOURCE SHELL.AURORA COMMANDS
$ShellAuroraPath = Join-Path $RepoPath "shell.aurora"
if (Test-Path $ShellAuroraPath) {
    if (-not (Select-String -Path $PROFILE -Pattern "shell.aurora" -Quiet)) {
        Add-Content -Path $PROFILE -Value ". `"$ShellAuroraPath`""
    }
}

Write-Host "✨ Aurora Shell v4.4.7 installed successfully!" -ForegroundColor Green
Write-Host "🔄 Restart your terminal to activate." -ForegroundColor Cyan
