# =============================================================
#  Rehan's Terminal Setup - one-command install
#  PowerShell 7 (pwsh) mein repo folder se chalayein:
#     .\install.ps1
# =============================================================

$repo  = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "    $msg" -ForegroundColor Yellow }

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# Purani file ka backup le kar nayi copy karo
function Place($src, $dst, $label) {
    if (!(Test-Path $src)) { Warn "$label repo mein nahi hai, skip"; return }
    $dir = Split-Path $dst
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (Test-Path $dst) { Copy-Item $dst "$dst.bak-$stamp" -Force }
    Copy-Item $src $dst -Force
    Ok "$label -> $dst"
}

function Winget-Install($id, $cmd) {
    if ($cmd -and (Get-Command $cmd -ErrorAction SilentlyContinue)) { Ok "$id already installed"; return }
    winget install --id $id -e --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) { Ok "$id installed" } else { Warn "$id install nahi hua (network block ho sakta hai)" }
}

Write-Host ""
Write-Host "  Rehan's Terminal Setup" -ForegroundColor Cyan
Write-Host "  by Muhammad Rehan  ·  github.com/RehanRajpoot1" -ForegroundColor DarkGray

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "`nYe script PowerShell 7 (pwsh) mein chalayein." -ForegroundColor Red
    Write-Host "Install: winget install Microsoft.PowerShell" -ForegroundColor Yellow
    exit 1
}

# ---- 1. CLI tools ----
Step "Tools (Oh My Posh, fzf, tldr, lazydocker)"
Winget-Install 'JanDeDobbeleer.OhMyPosh' 'oh-my-posh'
Winget-Install 'junegunn.fzf'            'fzf'
Winget-Install 'dbrgn.tealdeer'          'tldr'
Winget-Install 'JesseDuffield.lazydocker' 'lazydocker'
Refresh-Path

# ---- 2. Nerd Font ----
Step "CaskaydiaCove Nerd Font"
try { oh-my-posh font install CascadiaCode; Ok "Font installed" }
catch { Warn "Font install nahi hua. Baad mein: oh-my-posh font install CascadiaCode" }

# ---- 3. PowerShell modules ----
Step "Terminal-Icons module"
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Ok "Already installed"
} else {
    try {
        Install-Module Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force -ErrorAction Stop
        Ok "Installed"
    } catch {
        Warn "PowerShell Gallery tak nahi pahunch saka. Icons ke baghair bhi baqi setup chalega."
    }
}

# ---- 4. Config files ----
Step "Config files"
Place "$repo\powershell\Microsoft.PowerShell_profile.ps1" $PROFILE                  "PowerShell profile"
Place "$repo\oh-my-posh\rehan.omp.json"                   "$HOME\rehan.omp.json"    "Oh My Posh theme"
if (Test-Path "$HOME\.cheats.txt") {
    Ok "Cheat sheet pehle se hai, chhor diya (aap ki apni commands safe hain)"
} else {
    Place "$repo\cheats\cheats.txt" "$HOME\.cheats.txt" "Cheat sheet"
}

$wtDirs = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal"
) | Where-Object { Test-Path $_ }
if ($wtDirs) {
    foreach ($d in $wtDirs) { Place "$repo\windows-terminal\settings.json" "$d\settings.json" "Windows Terminal settings" }
} else {
    Warn "Windows Terminal nahi mila. Install: winget install Microsoft.WindowsTerminal"
}

# ---- 5. VS Code ----
Step "VS Code"
if (Get-Command code -ErrorAction SilentlyContinue) {
    Place "$repo\vscode\settings.json" "$env:APPDATA\Code\User\settings.json" "VS Code settings"

    if (Test-Path "$repo\vscode\extensions.txt") {
        $have = @(code --list-extensions 2>$null)
        $tmp  = Join-Path $env:TEMP "vsix-$stamp"
        New-Item -ItemType Directory -Path $tmp -Force | Out-Null

        foreach ($ext in Get-Content "$repo\vscode\extensions.txt" | Where-Object { $_.Trim() }) {
            if ($have -contains $ext) { Ok "$ext (already)"; continue }
            code --install-extension $ext 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) { Ok $ext; continue }

            # Fallback: marketplace se seedha download (IPv6 / CDN masle ke liye)
            $pub, $name = $ext.Split('.', 2)
            $file = Join-Path $tmp "$ext.vsix"
            try {
                Invoke-WebRequest "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$pub/vsextensions/$name/latest/vspackage" -OutFile $file -ErrorAction Stop
                code --install-extension $file 2>$null | Out-Null
                Ok "$ext (direct download)"
            } catch {
                Warn "$ext install nahi hui"
            }
        }
    }
} else {
    Warn "VS Code nahi mila, skip"
}

# ---- 6. tldr pages ----
Step "tldr cheat sheets"
if (Get-Command tldr -ErrorAction SilentlyContinue) { tldr --update | Out-Null; Ok "Updated" }

# ---- 7. Execution policy ----
Step "Execution policy"
if ((Get-ExecutionPolicy -Scope CurrentUser) -in 'Restricted', 'Undefined') {
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
    Ok "Set to RemoteSigned"
} else {
    Ok "Already OK"
}

Write-Host "`nSetup complete." -ForegroundColor Green
Write-Host "Windows Terminal ki poori window band karke dobara kholein." -ForegroundColor Green
Write-Host "VS Code transparency ke liye: Ctrl+Shift+P > 'Enable Vibrancy'" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Made with care by Muhammad Rehan" -ForegroundColor Magenta
Write-Host "  github.com/RehanRajpoot1/dotfiles" -ForegroundColor DarkGray
Write-Host ""
