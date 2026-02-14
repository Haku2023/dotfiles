if [[ -o interactive ]];then
  setopt extended_glob
# refer oh-my-zsh
setopt autocd
# Push the current directory visited on to the stack.
setopt auto_pushd
# Do not store duplicate directories in the stack.
setopt pushd_ignore_dups
setopt pushdminus
# Do not print the directory stack after using pushd or popd.
setopt pushd_silent
fi

# History options
# setopt append_history          # Append to history file instead of replacing
# setopt share_history           # Share history between all sessions
# setopt hist_ignore_dups        # Don't record duplicate entries
# setopt hist_ignore_all_dups    # Delete old duplicate entries
# setopt hist_ignore_space       # Don't record commands starting with space
# setopt hist_reduce_blanks      # Remove superfluous blanks
# setopt hist_verify             # Show command with history expansion before running
# setopt inc_append_history      # Write to history file immediately

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
