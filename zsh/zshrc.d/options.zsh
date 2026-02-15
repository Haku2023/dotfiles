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

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# not allowed > if file exist, using >|
setopt noclobber
