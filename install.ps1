# =============================================================
#  Rehan's Terminal Setup - one-command install
#  Run in PowerShell 7 (pwsh) from the repo folder:
#     .\install.ps1
# =============================================================

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "    $msg" -ForegroundColor Yellow }

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Ye script PowerShell 7 (pwsh) mein chalayein, Windows PowerShell 5.1 mein nahi." -ForegroundColor Red
    Write-Host "Install: winget install Microsoft.PowerShell" -ForegroundColor Yellow
    exit 1
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

# ---- 1. Oh My Posh ----
Step "Oh My Posh"
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Ok "Already installed"
} else {
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
    Ok "Installed"
}

# ---- 2. Nerd Font ----
Step "CaskaydiaCove Nerd Font"
try {
    oh-my-posh font install CascadiaCode
    Ok "Font installed"
} catch {
    Warn "Font install nahi hua. Baad mein chalayein: oh-my-posh font install CascadiaCode"
}

# ---- 3. Terminal-Icons ----
Step "Terminal-Icons module"
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Ok "Already installed"
} else {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force
    Ok "Installed"
}

# ---- 4. PowerShell profile ----
Step "PowerShell profile"
$profileDir = Split-Path $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.bak-$stamp"
    Ok "Purani profile backup: $PROFILE.bak-$stamp"
}
Copy-Item "$repo\powershell\Microsoft.PowerShell_profile.ps1" $PROFILE -Force
Ok "Profile copied to $PROFILE"

# ---- 5. Windows Terminal settings ----
Step "Windows Terminal settings"
$wtPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal"
)
$applied = $false
foreach ($dir in $wtPaths) {
    if (Test-Path $dir) {
        $target = Join-Path $dir 'settings.json'
        if (Test-Path $target) {
            Copy-Item $target "$target.bak-$stamp"
            Ok "Purani settings backup: $target.bak-$stamp"
        }
        Copy-Item "$repo\windows-terminal\settings.json" $target -Force
        Ok "Settings applied: $target"
        $applied = $true
    }
}
if (-not $applied) { Warn "Windows Terminal nahi mila. Install: winget install Microsoft.WindowsTerminal" }

# ---- 6. Execution policy ----
Step "Execution policy"
if ((Get-ExecutionPolicy -Scope CurrentUser) -in 'Restricted', 'Undefined') {
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
    Ok "Set to RemoteSigned"
} else {
    Ok "Already OK: $(Get-ExecutionPolicy)"
}

Write-Host "`nSetup complete. Terminal band karke dobara kholein." -ForegroundColor Green
