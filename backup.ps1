# =============================================================
#  Current terminal setup ko repo mein wapas copy karta hai.
#  Settings change karne ke baad chalayein, phir git commit/push.
#     .\backup.ps1
# =============================================================

$repo = $PSScriptRoot

$wtPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)

$wt = $wtPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($wt) {
    Copy-Item $wt "$repo\windows-terminal\settings.json" -Force
    Write-Host "Windows Terminal settings saved" -ForegroundColor Green
} else {
    Write-Host "Windows Terminal settings.json nahi mili" -ForegroundColor Yellow
}

if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$repo\powershell\Microsoft.PowerShell_profile.ps1" -Force
    Write-Host "PowerShell profile saved" -ForegroundColor Green
} else {
    Write-Host "PowerShell profile nahi mili: $PROFILE" -ForegroundColor Yellow
}

Write-Host "`nAb: git add . ; git commit -m 'update dotfiles' ; git push" -ForegroundColor Cyan
