# init homebrew, should be init first
if [[ "$(uname)" == "Darwin" ]];then
  # eval "$(/usr/local/bin/brew shellenv)"
  # arm 64
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[  "$(uname)" == "Linux"  ]];then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
### ---- FZF (better search) ----
# <<<{{{
# Use fd for fzf file finding (faster and respects .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Configure fzf default options
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border
  --inline-info
  --preview-window=right:50%:border-left
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-j:down,ctrl-k:up'"

# Configure fzf preview for Ctrl-T (file search)
export FZF_CTRL_T_OPTS="
  --preview 'bat --style=numbers --color=always --line-range :500 {}' 
  --preview-window right:60%:border-left
  --bind 'ctrl-/:toggle-preview'
  --header 'CTRL-/ to toggle preview'"

# Configure fzf preview for Alt-C (directory search)
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always --icons {} | head -200'
  --preview-window right:60%:border-left
  --bind 'ctrl-/:toggle-preview'
  --header 'CTRL-/ to toggle preview'"

# Configure fzf preview for Ctrl-R history search
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' 
  --preview-window up:3:wrap:hidden
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-/ to toggle preview, CTRL-Y to copy'"
eval "$(fzf --zsh)"
# <<<}}}

### ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
# Initialize mcfly AFTER zsh-vi-mode to prevent binding conflicts
# This ensures mcfly-history-widget is properly registered
eval "$(mcfly init zsh)"



# Set mcfly environment variables BEFORE initialization
# export MCFLY_KEY_SCHEME=vim
export MCFLY_RESULTS=50
# NOTE: mcfly init will be called in zvm_after_lazy_keybindings to avoid conflicts with zsh-vi-mode
#vim
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
