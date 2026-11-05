# ---- Prompt (Oh My Posh - Tokyo Night) ----
oh-my-posh init pwsh --config "$HOME\rehan.omp.json" | Invoke-Expression

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



# ---- Cheat sheet: Ctrl+G ya "cheat" ----
$CheatFile = "$HOME\.cheats.txt"

function Select-Cheat {
    param([string]$Query = '')
    if (-not (Test-Path $CheatFile)) {
        Write-Host "Cheat file nahi mili: $CheatFile" -ForegroundColor Yellow
        return
    }
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf install nahi hai: winget install junegunn.fzf" -ForegroundColor Yellow
        return
    }
    $pick = Get-Content $CheatFile |
        Where-Object { $_.Trim() -and $_ -notmatch '^\s*#' } |
        fzf --query "$Query" --height 60% --layout reverse --border rounded `
            --prompt 'cheat > ' --pointer '>' `
            --header 'Enter = chunein  |  Esc = band' `
            --color 'bg+:#283457,fg:#a9b1d6,fg+:#c0caf5,hl:#7aa2f7,hl+:#7dcfff,border:#414868,prompt:#bb9af7,pointer:#9ece6a,header:#565f89,info:#e0af68'
    if ($pick) { ($pick -split '\|', 3)[2].Trim() }
}

# Command chunein aur clipboard mein copy ho jaye
function cheat {
    param([string]$Query = '')
    $cmd = Select-Cheat $Query
    if ($cmd) {
        Set-Clipboard $cmd
        Write-Host "Copied: $cmd" -ForegroundColor Green
    }
}

# Naya cheat add karein:  cheat-add docker "Running containers" "docker ps"
function cheat-add {
    param(
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][string]$Command
    )
    Add-Content -Path $CheatFile -Value ("{0,-7} | {1,-45} | {2}" -f $Category, $Description, $Command) -Encoding utf8
    Write-Host "Added: $Description" -ForegroundColor Green
}

# Ctrl+G: chuni hui command seedha prompt mein aa jaye
Set-PSReadLineKeyHandler -Chord 'Ctrl+g' -BriefDescription 'Cheat sheet' -ScriptBlock {
    $line = $null; $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $cmd = Select-Cheat $line
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    if ($cmd) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($cmd)
    }
}

# ======================= Shortcuts =======================
Set-Alias k kubectl
function gs    { git status -sb }
function gsync { git pull --rebase; git push }
function glog  { git log --oneline --graph --decorate -20 }
function mkcd($d) { New-Item -ItemType Directory $d -Force | Out-Null; Set-Location $d }
function dps   { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function ..    { Set-Location .. }
function ...   { Set-Location ..\.. }

$FzfTheme = 'bg+:#283457,fg:#a9b1d6,fg+:#c0caf5,hl:#7aa2f7,hl+:#7dcfff,border:#414868,prompt:#bb9af7,pointer:#9ece6a,header:#565f89,info:#e0af68'

# ======================= proj: git projects mein jump =======================
function Get-Projects {
    $skip = 'AppData', 'OneDrive*', 'Music', 'Pictures', 'Videos', 'Saved Games', 'Searches', 'Contacts', 'Favorites', 'Links'
    Get-ChildItem $HOME -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $n = $_.Name; -not ($skip | Where-Object { $n -like $_ }) } |
        ForEach-Object { Get-ChildItem $_.FullName -Directory -Filter .git -Recurse -Depth 3 -Force -ErrorAction SilentlyContinue } |
        ForEach-Object { $_.Parent.FullName } | Sort-Object -Unique
}

function proj {
    param([string]$Query = '', [switch]$Code)
    $pick = Get-Projects | ForEach-Object { $_.Replace($HOME, '~') } |
        fzf --query "$Query" --height 50% --layout reverse --border rounded --prompt 'project > ' --header 'Enter = jao' --color $FzfTheme
    if ($pick) {
        Set-Location ($pick.Replace('~', $HOME))
        if ($Code) { code . }
    }
}
function projc { param([string]$Query = '') proj $Query -Code }

# ======================= sshp: servers par SSH =======================
function sshp {
    param([string]$Query = '')
    $cfg = "$HOME\.ssh\config"
    $hosts = @()
    if (Test-Path $cfg) {
        $hosts = Select-String -Path $cfg -Pattern '^\s*Host\s+(.+)$' |
            ForEach-Object { $_.Matches[0].Groups[1].Value -split '\s+' } |
            Where-Object { $_ -notmatch '[\*\?]' }
    }
    if (-not $hosts) {
        Write-Host "Koi server save nahi hai. Pehle add karein:" -ForegroundColor Yellow
        Write-Host '  ssh-add-host web1 13.235.10.20 ubuntu ~\keys\web1.pem' -ForegroundColor DarkGray
        return
    }
    $pick = $hosts | fzf --query "$Query" --height 40% --layout reverse --border rounded --prompt 'ssh > ' --header 'Enter = connect' --color $FzfTheme
    if ($pick) { ssh $pick }
}

function ssh-add-host {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$HostName,
        [string]$User = 'ubuntu',
        [string]$Key
    )
    $dir = "$HOME\.ssh"
    if (!(Test-Path $dir)) { New-Item -ItemType Directory $dir | Out-Null }
    $entry = "`nHost $Name`n    HostName $HostName`n    User $User"
    if ($Key) { $entry += "`n    IdentityFile $((Resolve-Path $Key).Path)" }
    Add-Content -Path "$dir\config" -Value $entry -Encoding ascii
    Write-Host "Added: $Name ($User@$HostName). Ab 'sshp' ya 'ssh $Name'" -ForegroundColor Green
}

# ======================= Shortcuts (banner ke neeche) =======================
function Show-Shortcuts {
    $r = $PSStyle.Reset
    $k = $c.Cyan; $d = $c.Gray; $h = $c.Purple
    Write-Host "  $($h)Shortcuts$r"
    Write-Host "  $($k)proj$r $($d)/$r $($k)projc$r   $($d)project kholo      $r$($k)sshp$r            $($d)server par SSH$r"
    Write-Host "  $($k)gs  gsync  glog$r  $($d)git                $r$($k)dps$r $($d)/$r $($k)k$r         $($d)docker / kubectl$r"
    Write-Host "  $($k)mkcd  ..  ...$r    $($d)folders            $r$($k)lazydocker$r      $($d)Docker UI$r"
    Write-Host "  $($k)Ctrl+G$r           $($d)cheat sheet        $r$($k)tl <topic>$r      $($d)tldr examples$r"
    Write-Host "  $($d)Poori list:$r $($k)hints$r"
    Write-Host ''
}

function hints {
    $r = $PSStyle.Reset
    $k = $c.Cyan; $d = $c.Gray; $h = $c.Purple
    $groups = [ordered]@{
        'Navigation' = @(
            @('proj [naam]',            'Git project chunein aur us folder mein jao'),
            @('projc [naam]',           'Project mein jao + VS Code kholo'),
            @('mkcd <folder>',          'Folder banao aur us mein jao'),
            @('.. / ...',               'Ek / do folder upar')
        )
        'Servers' = @(
            @('sshp',                   'Saved servers ki list, chun kar SSH'),
            @('ssh-add-host <naam> <ip> [user] [key.pem]', 'Naya server save karo')
        )
        'Git' = @(
            @('gs',                     'Short status'),
            @('gsync',                  'Pull (rebase) + push'),
            @('glog',                   'History graph ke saath')
        )
        'Docker / K8s' = @(
            @('dps',                    'Containers ki saaf table'),
            @('lazydocker',             'Docker ka terminal UI'),
            @('k <cmd>',                'kubectl ka shortcut (k get pods)')
        )
        'Help' = @(
            @('Ctrl+G',                 'Cheat sheet: command chuno, prompt mein aa jaye'),
            @('cheat [topic]',          'Cheat sheet se command clipboard mein'),
            @('cheat-add <cat> "<desc>" "<cmd>"', 'Apni command save karo'),
            @('tl <topic>',             'tldr pages ki list se chuno'),
            @('tldr <cmd>',             'Kisi bhi command ke examples'),
            @('Ctrl+R',                 'Purani commands search'),
            @('F1',                     'Likhi hui command ki help')
        )
    }
    Write-Host ''
    foreach ($g in $groups.Keys) {
        Write-Host "  $h$g$r"
        foreach ($row in $groups[$g]) { Write-Host ("    {0}{1,-42}{2}{3}{4}" -f $k, $row[0], $d, $row[1], $r) }
        Write-Host ''
    }
}




# ======================= Workflow helpers =======================
function fzfp {
    param([string]$Prompt = 'select', [string]$Header = 'Enter = chunein  |  Esc = band')
    $input | fzf --height 50% --layout reverse --border rounded --prompt "$Prompt > " --header $Header --color $FzfTheme
}

# ---- Docker ----
function dsh {
    $sel = docker ps --format "{{.Names}}`t{{.Image}}`t{{.Status}}" | fzfp 'container' 'Enter = shell kholo'
    if ($sel) { docker exec -it ($sel -split "`t")[0] sh -c 'command -v bash >/dev/null && exec bash || exec sh' }
}
function dlogs {
    $sel = docker ps -a --format "{{.Names}}`t{{.Image}}`t{{.Status}}" | fzfp 'container' 'Enter = live logs (Ctrl+C = band)'
    if ($sel) { docker logs -f --tail 200 ($sel -split "`t")[0] }
}
function dcu { docker compose up -d @args }
function dcd { docker compose down @args }
function dcl { docker compose logs -f @args }

# ---- Git ----
function gco {
    $b = git branch --all --format '%(refname:short)' 2>$null | Where-Object { $_ -notmatch 'HEAD|^origin$' } | fzfp 'branch'
    if ($b) { git switch ($b -replace '^origin/', '') }
}

# ---- Kubernetes ----
function kctx {
    $x = kubectl config get-contexts -o name 2>$null | fzfp 'k8s context'
    if ($x) { kubectl config use-context $x }
}
function kns {
    $x = kubectl get ns -o name 2>$null | ForEach-Object { $_ -replace '^namespace/', '' } | fzfp 'namespace'
    if ($x) { kubectl config set-context --current --namespace $x }
}

# ---- AWS EC2 ----
function ec2 {
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) { Write-Host "AWS CLI install nahi hai" -ForegroundColor Yellow; return }
    $rows = aws ec2 describe-instances --query "Reservations[].Instances[].[Tags[?Key=='Name']|[0].Value, InstanceId, State.Name, PublicIpAddress]" --output text 2>$null
    if (-not $rows) { Write-Host "Koi instance nahi mila. 'aws configure' aur region check karein." -ForegroundColor Yellow; return }
    $sel = $rows | fzfp 'ec2' 'Naam  ID  State  IP'
    if (-not $sel) { return }
    $name, $id, $state, $ip = $sel -split "`t"
    $action = 'start', 'stop', 'reboot', 'copy IP', 'copy ID' | fzfp "$name ($state)" 'Kya karna hai?'
    switch ($action) {
        'start'   { aws ec2 start-instances  --instance-ids $id --output table }
        'stop'    { aws ec2 stop-instances   --instance-ids $id --output table }
        'reboot'  { aws ec2 reboot-instances --instance-ids $id; Write-Host "Reboot: $name" -ForegroundColor Green }
        'copy IP' { Set-Clipboard $ip; Write-Host "Copied: $ip" -ForegroundColor Green }
        'copy ID' { Set-Clipboard $id; Write-Host "Copied: $id" -ForegroundColor Green }
    }
}

# ---- Network ----
function port([int]$p) {
    $conns = Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue
    if (-not $conns) { Write-Host "Port $p free hai" -ForegroundColor Green; return }
    $conns | Select-Object LocalAddress, LocalPort, State, OwningProcess,
        @{ n = 'Process'; e = { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } } |
        Format-Table -AutoSize
}
function killport([int]$p) {
    $ids = (Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue).OwningProcess | Sort-Object -Unique | Where-Object { $_ -gt 4 }
    if (-not $ids) { Write-Host "Port $p par koi process nahi" -ForegroundColor Green; return }
    foreach ($id in $ids) {
        $pr = Get-Process -Id $id -ErrorAction SilentlyContinue
        if ((Read-Host "Band karein $($pr.ProcessName) (PID $id)? y/n") -eq 'y') { Stop-Process -Id $id -Force; Write-Host "Band ho gaya" -ForegroundColor Green }
    }
}
function myip {
    $local = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)' } | Select-Object -First 1).IPAddress
    try { $public = Invoke-RestMethod 'https://api.ipify.org' -TimeoutSec 5 } catch { $public = 'nahi mila' }
    Write-Host "  Local : $local"
    Write-Host "  Public: $public"
}

# ---- Files ----
function fe {
    $f = fzf --height 60% --layout reverse --border rounded --prompt 'file > ' --header 'Enter = VS Code mein kholo' --color $FzfTheme
    if ($f) { code $f }
}

# ---- Shift shuru ----
function work {
    Write-Host "`n  Shift shuru..." -ForegroundColor Cyan
    if (-not (Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue)) {
        $dd = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
        if (Test-Path $dd) { Start-Process $dd; Write-Host "  Docker Desktop chalu" -ForegroundColor Green }
    } else { Write-Host "  Docker Desktop pehle se chal raha hai" -ForegroundColor Green }

    foreach ($repo in Get-Projects) {
        $name = Split-Path $repo -Leaf
        git -C $repo pull --ff-only --quiet 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Host "  pulled  $name" -ForegroundColor Green }
        else { Write-Host "  skip    $name (local changes ya conflict)" -ForegroundColor Yellow }
    }

    if (Get-Command aws -ErrorAction SilentlyContinue) {
        $acct = aws sts get-caller-identity --query Account --output text 2>$null
        if ($acct) { Write-Host "  AWS account: $acct" -ForegroundColor Green } else { Write-Host "  AWS login nahi hai" -ForegroundColor Yellow }
    }
    Write-Host ''
}

# ---- Dotfiles sync ----
function dotsync {
    param([string]$Msg = "update dotfiles $(Get-Date -Format 'yyyy-MM-dd')")
    Push-Location ~\dotfiles
    try {
        .\backup.ps1 | Out-Null
        git add -A
        if (-not (git status --porcelain)) { Write-Host "Kuch naya nahi" -ForegroundColor Green; return }
        git diff --cached --stat
        if ((Read-Host "`nYe changes push karein? y/n") -eq 'y') { git commit -m $Msg; git push }
    } finally { Pop-Location }
}

# ======================= Shortcuts box (banner ke neeche) =======================
function Show-Shortcuts {
    $r = $PSStyle.Reset; $k = $c.Cyan; $d = $c.Gray
    $rows = @(
        @('proj  projc',       'project kholo',  'sshp  ec2',     'servers'),
        @('gs gsync glog gco', 'git',            'dsh  dlogs',    'container shell/logs'),
        @('dps  dcu  dcd',     'docker',         'k  kctx  kns',  'kubernetes'),
        @('port  killport',    'ports',          'myip  fe',      'IP / file kholo'),
        @('work',              'shift shuru',    'dotsync',       'dotfiles push'),
        @('Ctrl+G',            'cheat sheet',    'hints',         'poori list')
    )
    Write-Host "  $($c.Purple)Shortcuts$r"
    foreach ($x in $rows) { Write-Host ("  {0}{1,-19}{2}{3,-16}{0}{4,-15}{2}{5}{6}" -f $k, $x[0], $d, $x[1], $x[2], $x[3], $r) }
    Write-Host ''
}

function hints {
    $r = $PSStyle.Reset; $k = $c.Cyan; $d = $c.Gray; $h = $c.Purple
    $groups = [ordered]@{
        'Navigation'   = @(@('proj [naam]', 'Git project chunein, us folder mein jao'), @('projc [naam]', 'Project + VS Code'), @('fe', 'File dhoondo, VS Code mein kholo'), @('mkcd <folder>', 'Folder banao + andar jao'), @('.. / ...', 'Ek / do folder upar'))
        'Servers'      = @(@('sshp', 'Saved servers, chun kar SSH'), @('ssh-add-host <naam> <ip> [user] [key]', 'Naya server save karo'), @('ec2', 'EC2 chuno: start / stop / reboot / IP'))
        'Git'          = @(@('gs', 'Short status'), @('gco', 'Branch chuno aur switch'), @('gsync', 'Pull (rebase) + push'), @('glog', 'History graph'))
        'Docker'       = @(@('dps', 'Containers ki table'), @('dsh', 'Container chuno, andar shell'), @('dlogs', 'Container chuno, live logs'), @('dcu / dcd / dcl', 'compose up -d / down / logs -f'), @('lazydocker', 'Docker ka terminal UI'))
        'Kubernetes'   = @(@('k <cmd>', 'kubectl shortcut'), @('kctx', 'Cluster badlo'), @('kns', 'Namespace badlo'))
        'Network'      = @(@('port <n>', 'Port kaun use kar raha'), @('killport <n>', 'Us process ko band karo'), @('myip', 'Local + public IP'))
        'Daily'        = @(@('work', 'Docker chalu + projects pull + AWS check'), @('dotsync', 'Dotfiles backup + push'))
        'Help'         = @(@('Ctrl+G', 'Cheat sheet, command prompt mein'), @('cheat-add <cat> "<desc>" "<cmd>"', 'Apni command save karo'), @('tl <topic> / tldr <cmd>', 'Command examples'), @('Ctrl+R', 'Purani commands search'), @('F1', 'Command ki help'))
    }
    Write-Host ''
    foreach ($g in $groups.Keys) {
        Write-Host "  $h$g$r"
        foreach ($row in $groups[$g]) { Write-Host ("    {0}{1,-40}{2}{3}{4}" -f $k, $row[0], $d, $row[1], $r) }
        Write-Host ''
    }
}

if (-not $env:DOTFILES_NO_BANNER) { Show-Shortcuts }
