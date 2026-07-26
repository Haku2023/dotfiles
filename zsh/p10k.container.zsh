# p10k config for the dotbox container only. Linked into place as
# $ZDOTDIR/.p10k.zsh by container/entrypoint.zsh; never used on a real host.
#
# Loads the shared config, then overrides the bits that only look wrong in a
# container. Keep host-relevant changes in p10k.zsh, not here.
source "$HOME/dotfiles/zsh/p10k.zsh"

# p10k.zsh's last line sets POWERLEVEL9K_CONFIG_FILE to its own path, so a
# `p10k configure` in here would overwrite the shared config and change macOS
# too. Repoint it at THIS file: the wizard then only ever rewrites the container
# config. Note it rewrites this file wholesale, dropping the overrides below —
# re-add them afterwards if you reconfigure.
# :A (not :a) resolves the .p10k.zsh symlink back to this file in the mounted
# repo, so wizard output persists on the host instead of dying with --rm.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:A}

# The container hostname is a random UUID, so %m is noise. Use a fixed label.
typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@apple container'
# Blue instead of p10k's root-warning red: being root here is normal, not risky.
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=4
