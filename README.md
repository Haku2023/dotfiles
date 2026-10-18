<div align="center">

# dotfiles

A personal setup for the terminal, editor, and desktop.

**macOS · Linux · Windows**

</div>

---

## What's inside

| Area | Configuration |
| :--- | :--- |
| Editor | [Neovim](nvim/), [VS Code](vscode/) |
| Terminal | [WezTerm](wezterm/) |
| Shell | [Zsh](zsh/) |
| Browser | [qutebrowser](qutebrowser/) |
| macOS desktop | [AeroSpace](aerospace/), [yabai](yabai/), [skhd](skhd/) |
| Linux desktop | [Hyprland](hypr/), [i3](i3/), [Waybar](waybar/), [Rofi](rofi/) |
| Keyboard | [Karabiner-Elements](macOS/karabiner-elements/), [keyd](keyd/), [AutoHotkey](autohotkey/) |

## Setup

Place this repository at `~/dotfiles` and install the applications you plan to use.

Review the installer, then run:

```sh
cd ~/dotfiles
zsh install_new.sh
```

The installer creates symlinks for:

- **Shared:** Zsh, Neovim, WezTerm, and qutebrowser.
- **macOS:** AeroSpace, yabai, and skhd.
- **Linux:** Hyprland.

Existing destinations are moved to `<destination>.backup` before linking. Back up anything important first; the script uses a fixed backup name.

> **WSL:** WezTerm configuration is skipped. Link or copy `wezterm/wezterm.lua` to your Windows user profile as `.wezterm.lua`.

## Configuration locations

### Shared tools

| Source | Platform | Destination |
| :--- | :--- | :--- |
| `nvim/` | macOS / Linux | `~/.config/nvim/` |
| `nvim/` | Windows | `%LOCALAPPDATA%\nvim\` |
| `wezterm/` | macOS | `~/.config/wezterm/` |
| `wezterm/wezterm.lua` | Linux | `~/.wezterm.lua` |
| `wezterm/wezterm.lua` | Windows | `%USERPROFILE%\.wezterm.lua` |
| `zsh/zshenv` | macOS / Linux | `~/.zshenv` |
| `zsh/zshrc` | macOS / Linux | `~/.config/zsh/.zshrc` |
| `zsh/external/` | macOS / Linux | `~/.config/zsh/external/` |
| `zsh/zshrc.d/` | macOS / Linux | `~/.config/zsh/zshrc.d/` |
| `qutebrowser/` | macOS | `~/.qutebrowser/` |
| `qutebrowser/` | Linux | `~/.config/qutebrowser/` |

### Desktop tools

| Source | Destination |
| :--- | :--- |
| `aerospace/` | `~/.config/aerospace/` |
| `yabai/` | `~/.config/yabai/` |
| `skhd/` | `~/.config/skhd/` |
| `hypr/` | `~/.config/hypr/` |
| `i3/` | `~/.config/i3/` |
| `waybar/` | `~/.config/waybar/` |
| `rofi/` | `~/.config/rofi/` |
| `keyd/default.conf` | `/etc/keyd/default.conf` |

Configurations outside the installer's scope must be set up manually.

## Make it yours

Edit the corresponding files in this repository. For configurations installed as symlinks, changes apply directly to their linked locations.

Reload or restart the relevant application after editing. Review personal paths, keyboard shortcuts, and machine-specific settings before using these configurations on another computer.
