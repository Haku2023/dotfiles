#!/bin/zsh
# Idempotently link dotfiles, then exec the requested command (zsh by default).
# ~/dotfiles is bind-mounted from the macOS host at runtime (HOME=/root).
set -e

if [[ -x "$HOME/dotfiles/install_new.sh" ]]; then
  zsh "$HOME/dotfiles/install_new.sh" || true
else
  echo "!! ~/dotfiles not mounted — run with: -v \$HOME/dotfiles:/root/dotfiles" >&2
fi

# Container-only: /root/.config isn't persisted, so p10k would re-run its wizard
# every start. Link the config in here rather than in install_new.sh, which is
# shared with macOS/Linux hosts that have their own .p10k.zsh.
# p10k.container.zsh sources the shared p10k.zsh, then overrides the container bits.
if [[ -f "$HOME/dotfiles/zsh/p10k.container.zsh" ]]; then
  mkdir -p "$HOME/.config/zsh"
  ln -sfn "$HOME/dotfiles/zsh/p10k.container.zsh" "$HOME/.config/zsh/.p10k.zsh"
fi

# Apple Container passes no TERM (or a minimal one), so zsh drops 24-bit colors
# (ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#d2691e') and nvim repaints badly -- after
# closing a big UI the screen stays blank until the cursor moves. Upgrade the
# thin values; anything richer the runtime passed through is left alone.
case "$TERM" in
  ''|dumb|linux|vt100|vt220|ansi|xterm) export TERM=xterm-256color ;;
esac
export COLORTERM="${COLORTERM:-truecolor}"

exec "$@"
