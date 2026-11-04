# dotfiles

My Windows terminal setup: **Windows Terminal + PowerShell 7 + Oh My Posh**, themed with **Tokyo Night**.

## What's inside

| Path | What it is |
|---|---|
| `windows-terminal/settings.json` | Windows Terminal config: Tokyo Night scheme, acrylic transparency, Nerd Font, custom tab |
| `powershell/Microsoft.PowerShell_profile.ps1` | PowerShell 7 profile: Oh My Posh prompt, Terminal-Icons, PSReadLine colors, history suggestions |
| `install.ps1` | One-command setup on a fresh machine |
| `backup.ps1` | Copies the current machine's config back into this repo |

## Features

- Tokyo Night color scheme with acrylic transparency (88%, 75% when unfocused)
- Oh My Posh prompt (`tokyonight_storm`) with git branch and status
- File and folder icons in `ls` via Terminal-Icons
- Syntax-colored command input via PSReadLine
- History-based suggestions in list view, `Tab` opens a completion menu
- CaskaydiaCove Nerd Font with extra line height

## Install on a new machine

Requirements: Windows 10/11, [Windows Terminal](https://aka.ms/terminal), PowerShell 7 (`winget install Microsoft.PowerShell`).

```powershell
git clone https://github.com/RehanRajpoot1/dotfiles.git
cd dotfiles
.\install.ps1
```

The script installs Oh My Posh, the Nerd Font, and Terminal-Icons, then copies the profile and terminal settings into place. Existing files are backed up with a `.bak-<timestamp>` suffix first.

Restart Windows Terminal when it finishes.

## Update the repo after changing settings

```powershell
.\backup.ps1
git add .
git commit -m "update dotfiles"
git push
```

## Customize

- **Transparency**: `opacity` in `windows-terminal/settings.json` (0-100)
- **Prompt theme**: replace `tokyonight_storm` in the profile with any [Oh My Posh theme](https://ohmyposh.dev/docs/themes)
- **Tab icon/name**: `icon` and `tabTitle` on the PowerShell profile in `settings.json`
