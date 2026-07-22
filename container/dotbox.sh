#!/bin/zsh
# Launch the dotfiles dev box in Apple Container.
#
# Usage:
#   dotbox                          # interactive zsh in /root
#   dotbox nvim                     # run a command (no project)
#   dotbox ~/projects/app           # mount project at /root/work, start there
#   dotbox ~/projects/app nvim .    # mount project, then run a command in it
#
# Rule: if the FIRST arg is an existing directory, it's the project; the rest is
# the command. Otherwise all args are the command.
#
# Persistence uses host bind-mounts (named volumes are broken in Apple Container 1.0).
# Container runs as root so these root-owned mounts are writable.
PERSIST="$HOME/.cache/dotbox"
mkdir -p "$PERSIST/share" "$PERSIST/state" "$PERSIST/cache"

project=()          # optional -v for the project
workdir=/root       # where the shell/command starts
if [[ -n "$1" && -d "$1" ]]; then
  proj=${1:A}       # resolve to absolute path
  project=(-v "$proj":/root/work)
  workdir=/root/work
  shift
fi

container run -it --rm \
  -m 4g \
  "${project[@]}" \
  -v "$HOME/dotfiles":/root/dotfiles \
  -v "$PERSIST/share":/root/.local/share \
  -v "$PERSIST/state":/root/.local/state \
  -v "$PERSIST/cache":/root/.cache \
  -w "$workdir" \
  dotbox "$@"
