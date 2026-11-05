# dotfiles

My Windows developer setup: **Windows Terminal + PowerShell 7 + Oh My Posh + VS Code**, all themed with **Tokyo Night**.

One script sets up a fresh machine. One script backs up the current one.

## What's inside

| Path | What it is |
|---|---|
| `windows-terminal/settings.json` | Tokyo Night scheme, acrylic transparency, Nerd Font, custom tab |
| `powershell/Microsoft.PowerShell_profile.ps1` | Prompt, icons, colors, suggestions, welcome banner, cheat sheet picker, `tl` helper |
| `oh-my-posh/rehan.omp.json` | Tokyo Night Storm prompt with a Docker context segment |
| `cheats/cheats.txt` | Personal DevOps cheat sheet (Docker, Kubernetes, Git, AWS, Azure, Terraform, Linux, PostgreSQL) |
| `vscode/settings.json` | VS Code: Tokyo Night, Material icons, Nerd Font, smooth cursor, transparency |
| `vscode/extensions.txt` | VS Code extensions to install |
| `install.ps1` | One-command setup on a fresh machine |
| `backup.ps1` | Copies the current machine's config back into this repo |

## Features

**Terminal**
- Tokyo Night colors with acrylic transparency
- Oh My Posh prompt with git status and the active Docker context
- File and folder icons in `ls` (Terminal-Icons)
- Syntax-colored input and history suggestions (PSReadLine)
- Welcome banner on every new tab

**Productivity**
- `Ctrl + G`: searchable cheat sheet. Pick a command and it lands in your prompt
- `cheat <topic>`: same picker, copies the command to the clipboard
- `cheat-add <category> "<description>" "<command>"`: save a new command
- `tl <topic>`: numbered picker over [tldr](https://tldr.sh) pages
- [lazydocker](https://github.com/jesseduffield/lazydocker): terminal UI for Docker

**VS Code**
- Tokyo Night theme and Material Icon Theme
- Same Nerd Font as the terminal, so the integrated terminal renders the prompt correctly
- Optional window transparency via Vibrancy Continued

## Install on a new machine

Requirements: Windows 10/11, [Windows Terminal](https://aka.ms/terminal), PowerShell 7 (`winget install Microsoft.PowerShell`), Git.

```powershell
git clone https://github.com/RehanRajpoot1/dotfiles.git
cd dotfiles
.\install.ps1
```

The script:
1. Installs Oh My Posh, fzf, tealdeer (tldr), and lazydocker with winget
2. Installs the CaskaydiaCove Nerd Font and the Terminal-Icons module
3. Copies the profile, prompt theme, terminal settings, and VS Code settings into place
4. Installs the VS Code extensions (falls back to a direct download if the marketplace CDN is unreachable)

Existing files are backed up with a `.bak-<timestamp>` suffix first. An existing `~\.cheats.txt` is never overwritten.

When it finishes, close Windows Terminal completely and reopen it.

For VS Code transparency, run **Enable Vibrancy** from the command palette (`Ctrl + Shift + P`) once.

## Update the repo after changing something

```powershell
.\backup.ps1
git diff          # check nothing secret slipped in
git add .
git commit -m "update dotfiles"
git push
```

## Customize

- **Terminal transparency**: `opacity` in `windows-terminal/settings.json` (0-100)
- **VS Code transparency**: `vscode_vibrancy.opacity` in `vscode/settings.json` (0-1)
- **Prompt**: edit `oh-my-posh/rehan.omp.json`, or browse [Oh My Posh themes](https://ohmyposh.dev/docs/themes)
- **Tab icon/name**: `icon` and `tabTitle` on the PowerShell profile in `windows-terminal/settings.json`
- **Turn off the banner**:
  ```powershell
  [Environment]::SetEnvironmentVariable('DOTFILES_NO_BANNER', '1', 'User')
  ```

## Troubleshooting

- **`Install-Module` or VS Code extensions time out**: some networks have no working IPv6 route. The install script falls back to direct downloads where it can. To make Windows prefer IPv4, run in an admin PowerShell, then restart:
  ```powershell
  New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -PropertyType DWord -Value 0x20 -Force
  ```
- **Boxes instead of icons**: the Nerd Font isn't set. Check the `font.face` in Windows Terminal settings.
- **A newly installed command isn't found**: close the whole Windows Terminal window and reopen it.

---

Made by **Muhammad Rehan**, DevOps Engineer · [github.com/RehanRajpoot1](https://github.com/RehanRajpoot1)
