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

# Set HISTFILE here (not in zshenv) because macOS /etc/zshrc overrides it with $ZDOTDIR/.zsh_history
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# History settings moved to options.zsh (must be set after /etc/zshrc which overrides HISTFILE)
export HISTSIZE=50000
export SAVEHIST=10000


setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# not allowed > if file exist, using >|
setopt noclobber
