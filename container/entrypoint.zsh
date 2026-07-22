#!/bin/zsh
# Idempotently link dotfiles, then exec the requested command (zsh by default).
# ~/dotfiles is bind-mounted from the macOS host at runtime (HOME=/root).
set -e

if [[ -x "$HOME/dotfiles/install_new.sh" ]]; then
  zsh "$HOME/dotfiles/install_new.sh" || true
else
  echo "!! ~/dotfiles not mounted — run with: -v \$HOME/dotfiles:/root/dotfiles" >&2
fi

exec "$@"
