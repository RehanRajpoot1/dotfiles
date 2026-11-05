# =============================================================
#  Is PC ka current setup repo mein copy karta hai.
#  Kuch bhi change karne ke baad chalayein, phir git push.
#     .\backup.ps1
# =============================================================

$repo = $PSScriptRoot

function Save($src, $dst, $label) {
    if (Test-Path $src) {
        $dir = Split-Path $dst
        if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Copy-Item $src $dst -Force
        Write-Host "  [ok]   $label" -ForegroundColor Green
    } else {
        Write-Host "  [skip] $label (nahi mila)" -ForegroundColor Yellow
    }
}

Write-Host "`nBacking up..." -ForegroundColor Cyan

# Windows Terminal
$wt = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
Save $wt "$repo\windows-terminal\settings.json" "Windows Terminal settings"

# PowerShell profile + prompt theme + cheat sheet
Save $PROFILE                  "$repo\powershell\Microsoft.PowerShell_profile.ps1" "PowerShell profile"
Save "$HOME\rehan.omp.json"    "$repo\oh-my-posh\rehan.omp.json"                   "Oh My Posh theme"
Save "$HOME\.cheats.txt"       "$repo\cheats\cheats.txt"                           "Cheat sheet"

# VS Code
Save "$env:APPDATA\Code\User\settings.json" "$repo\vscode\settings.json" "VS Code settings"
if (Get-Command code -ErrorAction SilentlyContinue) {
    New-Item -ItemType Directory -Path "$repo\vscode" -Force | Out-Null
    code --list-extensions 2>$null | Set-Content "$repo\vscode\extensions.txt" -Encoding utf8
    Write-Host "  [ok]   VS Code extensions list" -ForegroundColor Green
}

Write-Host "`nPush karne se pehle check kar lein ke koi password ya secret to nahi aa gaya:" -ForegroundColor Yellow
Write-Host "  git diff" -ForegroundColor DarkGray
Write-Host "`nPhir:  git add . ; git commit -m 'update dotfiles' ; git push`n" -ForegroundColor Cyan
