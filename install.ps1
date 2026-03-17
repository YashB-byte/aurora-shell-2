# --- AURORA-SHELL WINDOWS MASTER v5.3 (Hard-Coded Header) ---
$INSTALL_PATH = "$HOME\.aurora-shell"
$CONFIG_FILE = "$HOME\.aurorasettings"
if (!(Test-Path $INSTALL_PATH)) { New-Item -ItemType Directory -Path $INSTALL_PATH }

Write-Host "🌟 Aurora-Shell Universal Installer (Windows) v5.3" -ForegroundColor Cyan

# 1. FIXED HEADER CONFIGURATION
# No more selection menu; Block Art is now the standard.
$HEADER_TYPE = "BLOCK"
$HEADER_TEXT = "Aurora-Shell"

# 2. PROMPT CONFIGURATION
Write-Host "`n--- STEP 1: PROMPT STYLE ---" -ForegroundColor Green
Write-Host "1) Default    (Aurora-Shell ✨ Time >)"
Write-Host "2) Minimalist (Time >)"
$p_choice = Read-Host "Selection [1-2]"

switch ($p_choice) {
    "1" { $FINAL_ID = "Aurora-Shell" }
    "2" { $FINAL_ID = "" }
    default { $FINAL_ID = "Aurora-Shell" }
}

# 3. SECURITY
$NEW_PASS = Read-Host "🔐 Set Master Password (Leave blank for none)" -AsSecureString
$PLAIN_PASS = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NEW_PASS))

# 4. CREATE PERSISTENT CONFIG
$ConfigContent = @"
AURORA_HEADER_TYPE="$HEADER_TYPE"
AURORA_HEADER_TEXT="$HEADER_TEXT"
AURORA_HEADER_VISIBLE="ON"
AURORA_STATS="ON"
AURORA_TIME_VISIBLE="ON"
AURORA_PASS_ENABLED="ON"
AURORA_PWD="$PLAIN_PASS"
AURORA_ID="$FINAL_ID"
AURORA_MOTD="Welcome to the void."
"@
$ConfigContent | Out-File -FilePath $CONFIG_FILE -Encoding utf8

# 5. GENERATE THEME ENGINE (PowerShell Profile)
$THEME_FILE = "$INSTALL_PATH\aurora_theme.ps1"

$ThemeScript = @'
function Show-AuroraDisplay {
    $window_width = $Host.UI.RawUI.WindowSize.Width
    
    # The Hard-Coded Master Header
    $header = @"
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
    Write-Host $header -ForegroundColor Cyan
    
    # Stats Line
    $date = Get-Date -Format "MM/dd/yy"
    $stats = "📅 $date | 🧠 Aurora Active"
    Write-Host $stats.PadLeft([int]($window_width/2 + $stats.Length/2)) -ForegroundColor DarkCyan
}

function aurora {
    param([string]$action)
    switch ($action) {
        "--status" { Get-Content "$HOME\.aurorasettings" }
        "--uninstall" { 
            Remove-Item "$HOME\.aurora-shell" -Recurse -ErrorAction SilentlyContinue
            Remove-Item "$HOME\.aurorasettings" -ErrorAction SilentlyContinue
            Write-Host "🗑️ Removed." -ForegroundColor Red
        }
        default { Show-AuroraDisplay }
    }
}
'@
$ThemeScript | Out-File -FilePath $THEME_FILE -Encoding utf8

# 6. SYNC TO PROFILE
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
$ProfileContent = Get-Content $PROFILE
if ($ProfileContent -notlike "*$THEME_FILE*") {
    Add-Content -Path $PROFILE -Value "`n. `"$THEME_FILE`""
}

Write-Host "`n✅ v5.3 Installed with Classic Header! Restart PowerShell." -ForegroundColor Green