# ---- Prompt (Oh My Posh - Tokyo Night) ----
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/tokyonight_storm.omp.json' | Invoke-Expression

# ---- File icons in ls ----
Import-Module Terminal-Icons

# ---- Tokyo Night colors ----
$c = @{
    Blue   = $PSStyle.Foreground.FromRgb(0x7AA2F7)
    Green  = $PSStyle.Foreground.FromRgb(0x9ECE6A)
    Purple = $PSStyle.Foreground.FromRgb(0xBB9AF7)
    Cyan   = $PSStyle.Foreground.FromRgb(0x7DCFFF)
    Orange = $PSStyle.Foreground.FromRgb(0xE0AF68)
    Red    = $PSStyle.Foreground.FromRgb(0xF7768E)
    Gray   = $PSStyle.Foreground.FromRgb(0x565F89)
    Text   = $PSStyle.Foreground.FromRgb(0xC0CAF5)
}

Set-PSReadLineOption -Colors @{
    Command          = $c.Blue
    Parameter        = $c.Orange
    String           = $c.Green
    Variable         = $c.Purple
    Number           = $c.Cyan
    Operator         = $c.Cyan
    Keyword          = $c.Purple
    Comment          = $c.Gray
    Default          = $c.Text
    Error            = $c.Red
    InlinePrediction = $c.Gray
}

# ---- Auto-suggestions ----
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# ---- Welcome banner ----
# Band karna ho to: [Environment]::SetEnvironmentVariable('DOTFILES_NO_BANNER', '1', 'User')
function Show-Banner {
    $r = $PSStyle.Reset
    $art = @(
        ' ____  _____ _   _    _    _   _ '
        '|  _ \| ____| | | |  / \  | \ | |'
        '| |_) |  _| | |_| | / _ \ |  \| |'
        '|  _ <| |___|  _  |/ ___ \| |\  |'
        '|_| \_\_____|_| |_/_/   \_\_| \_|'
    )
    $shades = @($c.Cyan, $c.Blue, $c.Blue, $c.Purple, $c.Purple)

    Write-Host ''
    for ($i = 0; $i -lt $art.Count; $i++) {
        Write-Host "  $($shades[$i])$($art[$i])$r"
    }
    Write-Host ''
    Write-Host "  $($c.Gray)Terminal setup crafted by $r$($c.Orange)Muhammad Rehan$r $($c.Gray)· DevOps Engineer$r"
    Write-Host "  $($c.Gray)github.com/RehanRajpoot1/dotfiles$r"
    Write-Host ''
    Write-Host "  $($c.Gray)PowerShell $($PSVersionTable.PSVersion) · $(Get-Date -Format 'ddd, dd MMM yyyy  hh:mm tt')$r"
    Write-Host ''
    Write-Host ''
}

if (-not $env:DOTFILES_NO_BANNER) { Show-Banner }

