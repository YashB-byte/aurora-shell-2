!include "MUI2.nsh"

Name "Aurora-Shell"
OutFile "Aurora-Shell-Installer.exe"
InstallDir "$PROFILE\.aurora-shell"
RequestExecutionLevel user ; No admin required!

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

Section "Install"
    SetOutPath $INSTDIR
    
    ; 1. Pack the PowerShell script into the EXE
    File "install.ps1"
    
    ; 2. Run the PowerShell script silently after extraction
    ; -ExecutionPolicy Bypass ensures the script isn't blocked by Windows security
    DetailPrint "Running Aurora-Shell setup..."
    ExecWait 'powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "$INSTDIR\install.ps1"'
    
    ; 3. Cleanup the script after it runs
    Delete "$INSTDIR\install.ps1"
SectionEnd