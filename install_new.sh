#!/bin/bash

mkdir -p "$HOME/.config/zsh"
ln -sf "$HOME/dotfiles/zsh/zshenv" "$HOME/.zshenv"
ln -sf "$HOME/dotfiles/zsh/zshrc" "$HOME/.config/zsh/.zshrc"
ln -sf "$HOME/dotfiles/zsh/zprofile" "$HOME/.config/zsh/.zprofile"
