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

export DOTFILES="${HOME}/dotfiles"
if [[ -n "$WSL_DISTRO_NAME" ]]; then
	export BROWSER=wslview
else
	export BROWSER=qutebrowser
fi

# Compilation flags for mac to get the arch compatibale
if [[ "$(uname)" == "Darwin" ]]; then
	export ARCHFLAGS="-arch $(uname -m)"
fi
#
# brew update frequency
export HOMEBREW_AUTO_UPDATE_SECS=86400 # Update at most once per day
export HOMEBREW_NO_ENV_HINTS=1

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
if [[ -n "$WSL_DISTRO_NAME" ]]; then
	path+=(/mnt/c/Windows)
fi

export MANPATH="/usr/local/man:$MANPATH"
# Latex
if [[ "$(uname)" == "Linux" && -z "$WSL_DISTRO_NAME" ]]; then
	# turn off flow control
	# stty -ixon
	# only on real linux, start-hyprland
	if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
		exec start-hyprland
	fi
	export MANPATH="/usr/local/texlive/2025/texmf-dist/doc/man:$MANPATH"
	export INFOPATH="/usr/local/texlive/2025/texmf-dist/doc/info:$INFOPATH"
	path+=(/usr/local/texlive/2025/bin/x86_64-linux)
elif [[ "$(uname)" == "Darwin" ]]; then
	# Path to llvm clange
	path+=(/usr/local/opt/llvm/bin)
	# Path to wezterm
	path+=(/Applications/Wezterm.app/Contents/Macos)
	# Path to Latex
	path+=(/Library/Tex/texbin)
fi
