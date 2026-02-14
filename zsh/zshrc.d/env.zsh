# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local(vim) and remote(nvim) sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
  export VISUAL='vim'
else
  export EDITOR='nvim'
  export VISUAL='nvim'
fi

export TERMINAL=wezterm
export BROWSER=qutebrowser

export DOTFILES="${HOME}/dotfiles"

# Compilation flags for mac to get the arch compatibale 
if [[ "$(uname)" == "Darwin" ]];then
  export ARCHFLAGS="-arch $(uname -m)"
fi
#
# brew update frequency
export HOMEBREW_AUTO_UPDATE_SECS=86400   # Update at most once per day
export HOMEBREW_NO_ENV_HINTS=1

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# Maximum events for internal history
export HISTFILE="$ZDOTDIR/history.zsh"
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
export HISTSIZE=50000
export SAVEHIST=10000

# export multi selection with tab
export FZF_DEFAULT_OPTS='-m'



# Make path array unique (removes duplicates automatically)
typeset -U path

# Define path entries (zsh automatically syncs path array with PATH string)
path=(
  $HOME/bin
  $HOME/.local/bin
  /usr/local/bin
  /usr/bin
  /bin
  )

# Add WSL-specific path
if [[ -n "$WSL_DISTRO_NAME"  ]] ;then
  path+=(/mnt/c/Windows)
fi

# set .local/bin in path
export MANPATH="/usr/local/man:$MANPATH"
# Latex
if [[ "$(uname)" == "Linux" ]];then
  export MANPATH="/usr/local/texlive/2025/texmf-dist/doc/man:$MANPATH"
  export INFOPATH="/usr/local/texlive/2025/texmf-dist/doc/info:$INFOPATH"
  path+=(/usr/local/texlive/2025/bin/x86_64-linux)
elif [[ "$(uname)" == "Darwin" ]];then
  # Path to llvm clange
  export path+=(/usr/local/opt/llvm/bin)
  # Path to wezterm
  export path+=(/Applications/Wezterm.app/Contents/Macos)
  # Path to Latex
  export path+=(/Library/Tex/texbin)
fi


# only on real linux, start-hyprland
# <<<{{{
if [[ -z "$WSL_DISTRO_NAME"  ]] && [[ "$(uname)" == "Linux" ]]; then
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec start-hyprland
fi
fi
#<<<}}}


# conda initialize
# <<<{{{
__conda_setup="$("${HOME}/Tools/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/Tools/miniconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/Tools/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/Tools/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<}}}
#
# k
