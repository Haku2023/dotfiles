#!/bin/zsh

set -euo pipefail  # Exit on error, undefined vars, pipe failures

DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"

# Verify dotfiles directory exists
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Error: $DOTFILES_DIR not found" >&2
    exit 1
fi

echo "Creating directories..."
mkdir -p "${CONFIG_DIR}"
mkdir -p "${CONFIG_DIR}/zsh-plugins"
mkdir -p "${CONFIG_DIR}/zsh"

# Function to create symlink safely
link_file() {
    local src="$1"
    local dest="$2"
    
    if [[ ! -e "$src" ]]; then
        echo "Warning: Source $src doesn't exist, skipping" >&2
        return 1
    fi
    
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        echo "✓ $dest already linked correctly"
        return 0
    fi
    
    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "Backing up existing $dest to ${dest}.backup"
        mv "$dest" "${dest}.backup"
    fi
    
    ln -sfn "$src" "$dest"
    echo "✓ Linked $dest -> $src"
}

# Create symlinks
print "Creating symlinks..."

print "=> create zsh symbols"

link_file "${DOTFILES_DIR}/zsh/zshenv" "${HOME}/.zshenv"
link_file "${DOTFILES_DIR}/zsh/zshrc" "${CONFIG_DIR}/zsh/.zshrc"
link_file "${DOTFILES_DIR}/zsh/zprofile" "${CONFIG_DIR}/zsh/.zprofile"
link_file "${DOTFILES_DIR}/zsh/external" "${CONFIG_DIR}/zsh/external"
link_file "${DOTFILES_DIR}/zsh/zshrc.d" "${CONFIG_DIR}/zsh/zshrc.d"

print "=> create nvim symbols"

link_file "${DOTFILES_DIR}/nvim" "${CONFIG_DIR}/nvim"

print "=> create wezterm symbols"
link_file "${DOTFILES_DIR}/wezterm" "${CONFIG_DIR}/wezterm"

print "=> create qutebrowser symbols"
if [[ "$(uname)" == "Linux" ]]; then
link_file "${DOTFILES_DIR}/qutebrowser" "${CONFIG_DIR}/qutebrowser"
elif [[ "$(uname)" == "Darwin" ]]; then
link_file "${DOTFILES_DIR}/qutebrowser" "$HOME/.qutebrowser"
fi

if [[ "$(uname)" == "Linux" ]]; then
  print "=> create hyprland symbols"
  link_file "${DOTFILES_DIR}/hypr" "${CONFIG_DIR}/hypr"
fi

echo "Installation complete!"
