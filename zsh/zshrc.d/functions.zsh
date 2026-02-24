
if [[ "$(uname)" == "Darwin" ]];then
  wsh () {
    wezterm cli spawn --domain-name "SSH:$1"
  }
  # Use zsh completion
  _wsh() {
    _arguments '1:server:(73 117 109)'  # Shows "server" as description
  }
  compdef _wsh wsh
elif [[ -n "$WSL_DISTRO_NAME"  ]] ;then
  haku26() {
    case "$1" in
      "73")
      /mnt/c/cygwin64/home/baihaodong/Projects/Yodo_26/
      ;;
      "69")
      /mnt/c/Users/baihd/source/repos/H-FRESH_2026/
      ;;
      *)
      print "Please Specify the work station"
      ;;
    esac
  }
  _haku26() {
    _arguments '1:work_station:(69 73)'
  }
  compdef _haku26 haku26
fi
bindkey '^ ' autosuggest-accept

# haku useful functions cdn mcd lsn
# >>>>>>>>>>>>>>>>{{{
# cdn - cd to newest directory, or nth newest with argument
cdn() {
  local n=${1:-1}
  new_file=$(eza -snew -D --icons=never | tail -n${n} | head -n1)
  cd ${new_file}
}
# mkdir,cd it
mcd() {
mkdir $1
cd $1
}
# find the latest files in current directory
# lso(){
# find . -type f -exec ls -lt {} + | head -$1
# }
lsh(){
  ls -ld -s="modified" **/*(D.om[1,$1])
}
# set start and end function to calc time
haku_start() {
    start_time=$(date +%s)
}
haku_end() {
    end_time=$(date +%s)
    mid_time=$(($end_time - $start_time));hours_calc=$((mid_time/3600));mins_calc=$((mid_time%3600/60));seconds_calc=$((mid_time%60))
    printf "elapsed time is : %d h %d min %d s\n" $hours_calc $mins_calc $seconds_calc

}
# mac / linux
if [[ "$(uname)" == "Darwin" ]];then
paste-from-clipboard() {
  RBUFFER=${RBUFFER:0:1}$(pbpaste)${RBUFFER:1}
  zle end-of-line
  zvm_enter_insert_mode
}
elif [[  "$(uname)" == "Linux"  ]];then
paste-from-clipboard() {
  RBUFFER=${RBUFFER:0:1}`(xsel -b -o)`${RBUFFER:1}
  zle end-of-line
  zvm_enter_insert_mode
}
fi
# Prepend 'sudo' to the current command line with Ctrl+S
prepend-sudo() {
  if [[ -z "$BUFFER" ]];then
    BUFFER="sudo $(fc -ln -1)" 
    zle end-of-line
  else
    BUFFER="sudo ${BUFFER}" 
    zle end-of-line
    # zle beginning-of-line
    # zle -U " sudo "
    # zle end-of-line
  fi
}
# v to insert v
v2iv() {
  if [[ -z "$BUFFER" ]];then
    BUFFER="v" 
    zle end-of-line
    zvm_enter_insert_mode
  else
    zvm_enter_visual_mode
  fi
}

# Make a widget that sends the escape sequence for Alt+Left Arrow
alt_left() {
  # \e is ESC. This simulates pressing Alt+Left
  zle -U $'\e[1;3D'
}
# Make a widget that sends the escape sequence for Alt+Left Arrow
alt_right() {
  # \e is ESC. This simulates pressing Alt+Left
  zle -U $'\e[1;3C'
}
# Make a widget that sends the escape sequence for Alt+Left Arrow
alt_up() {
  # \e is ESC. This simulates pressing Alt+Left
  zle -U $'\e[1;3A'
}
open-nvim() {
  nvim
  zle reset-prompt
}
# Force insert mode at each new prompt
# zle-line-init() {
#   zle -K viins   # switch to vi insert keymap
# }
# zle-line-finish() { zle -K viins }

# Always enter insert mode after Ctrl-C
# _ins_after_break() {
#   zle send-break        # do what Ctrl-C normally does
#   zle -K viins          # then force vi-insert keymap for the new line
#}
# zle -N _ins_after_break
# zle -N zle-line-init
# zle -N zle-line-finish
# zle -N alt_left
# zle -N alt_right
# zle -N alt_up
zle -N open-nvim
zle -N paste-from-clipboard
zle -N v2iv
zle -N prepend-sudo

# function zvm_before_init_commands=()
zvm_after_init_commands+=(
#   #for dirhistory
  "bindkey -s '^K' '^[[1;3A'" "bindkey -M vicmd -s '^K' '^[[1;3A'"
  "bindkey -s '^U' '^[[1;3C'" "bindkey -M vicmd -s '^U' '^[[1;3C'" 
  "bindkey -s '^O' '^[[1;3D'" "bindkey -M vicmd -s '^O' '^[[1;3D'"
  "bindkey '^J' open-nvim" "bindkey -M vicmd '^J' open-nvim"
  "bindkey '^H' backward-delete-char"
  "bindkey '^V' paste-from-clipboard"
  "bindkey '^S' prepend-sudo"
 )
function zvm_before_lazy_keybindings(){}


function zvm_after_lazy_keybindings() {
  bindkey -M vicmd '^S' prepend-sudo
  bindkey -M vicmd 'v' v2iv
  bindkey -M vicmd 'p' paste-from-clipboard
  
  
  # C-r for mcfly in insert mode (vi insert mode) - AI-powered history search
  bindkey -M vicmd '^R' mcfly-history-widget
  
  # C-r for fzf history in normal mode (vi command mode) - fuzzy search
  bindkey -M viins '^R' fzf-history-widget
}

# Start in command mode (this is the key part)
# zle-line-init() { zle -K vicmd; }
# <<<<<<<<<<<<<<<<# }}}

# refer oh-my-zsh
#d(){{{
function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d
#<<}}}
#omz_history(){{{
function omz_history {
  # parse arguments and remove from $@
  local clear list stamp REPLY
  zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp t:=stamp

  if [[ -n "$clear" ]]; then
    # if -c provided, clobber the history file

    # confirm action before deleting history
    print -nu2 "This action will irreversibly delete your command history. Are you sure? [y/N] "
    builtin read -E
    [[ "$REPLY" = [yY] ]] || return 0

    print -nu2 >| "$HISTFILE"
    fc -p "$HISTFILE"

    print -u2 History file deleted.
  elif [[ $# -eq 0 ]]; then
    # if no arguments provided, show full history starting from 1
    builtin fc "${stamp[@]}" -l 1
  else
    # otherwise, run `fc -l` with a custom format
    builtin fc "${stamp[@]}" -l "$@"
  fi
}
#<<<}}}
# Navigate directory history using ALT-Navs{{{
dirhistory_past=($PWD)
dirhistory_future=()
export dirhistory_past
export dirhistory_future
export DIRHISTORY_SIZE=30

alias cde='dirhistory_cd'

# Pop the last element of dirhistory_past.
# Pass the name of the variable to return the result in.
# Returns the element if the array was not empty,
# otherwise returns empty string.
function pop_past() {
  setopt localoptions no_ksh_arrays
  if [[ $#dirhistory_past -gt 0 ]]; then
    typeset -g $1="${dirhistory_past[$#dirhistory_past]}"
    dirhistory_past[$#dirhistory_past]=()
  fi
}

function pop_future() {
  setopt localoptions no_ksh_arrays
  if [[ $#dirhistory_future -gt 0 ]]; then
    typeset -g $1="${dirhistory_future[$#dirhistory_future]}"
    dirhistory_future[$#dirhistory_future]=()
  fi
}

# Push a new element onto the end of dirhistory_past. If the size of the array
# is >= DIRHISTORY_SIZE, the array is shifted
function push_past() {
  setopt localoptions no_ksh_arrays
  if [[ $#dirhistory_past -ge $DIRHISTORY_SIZE ]]; then
    shift dirhistory_past
  fi
  if [[ $#dirhistory_past -eq 0 || $dirhistory_past[$#dirhistory_past] != "$1" ]]; then
    dirhistory_past+=($1)
  fi
}

function push_future() {
  setopt localoptions no_ksh_arrays
  if [[ $#dirhistory_future -ge $DIRHISTORY_SIZE ]]; then
    shift dirhistory_future
  fi
  if [[ $#dirhistory_future -eq 0 || $dirhistory_futuret[$#dirhistory_future] != "$1" ]]; then
    dirhistory_future+=($1)
  fi
}

# Called by zsh when directory changes
autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd_dirhistory
function chpwd_dirhistory() {
  push_past $PWD
  # If DIRHISTORY_CD is not set...
  if [[ -z "${DIRHISTORY_CD+x}" ]]; then
    # ... clear future.
    dirhistory_future=()
  fi
}

function dirhistory_cd(){
  DIRHISTORY_CD="1"
  cd $1
  unset DIRHISTORY_CD
}

# Move backward in directory history
function dirhistory_back() {
  local cw=""
  local d=""
  # Last element in dirhistory_past is the cwd.

  pop_past cw
  if [[ "" == "$cw" ]]; then
    # Someone overwrote our variable. Recover it.
    dirhistory_past=($PWD)
    return
  fi

  pop_past d
  if [[ "" != "$d" ]]; then
    dirhistory_cd $d
    push_future $cw
  else
    push_past $cw
  fi
}


# Move forward in directory history
function dirhistory_forward() {
  local d=""

  pop_future d
  if [[ "" != "$d" ]]; then
    dirhistory_cd $d
    push_past $d
  fi
}


# Bind keys to history navigation
function dirhistory_zle_dirhistory_back() {
  # Erase current line in buffer
  zle .kill-buffer
  dirhistory_back
  zle .accept-line
}

function dirhistory_zle_dirhistory_future() {
  # Erase current line in buffer
  zle .kill-buffer
  dirhistory_forward
  zle .accept-line
}

zle -N dirhistory_zle_dirhistory_back
zle -N dirhistory_zle_dirhistory_future

for keymap in emacs vicmd viins; do
  # dirhistory_back
  bindkey -M $keymap "\e[3D" dirhistory_zle_dirhistory_back    # xterm in normal mode
  bindkey -M $keymap "\e[1;3D" dirhistory_zle_dirhistory_back  # xterm in normal mode
  bindkey -M $keymap "\e\e[D" dirhistory_zle_dirhistory_back   # Putty
  bindkey -M $keymap "\eO3D" dirhistory_zle_dirhistory_back    # GNU screen

  case "$TERM_PROGRAM" in
  Apple_Terminal) bindkey -M $keymap "^[b" dirhistory_zle_dirhistory_back ;; # Terminal.app
  ghostty) bindkey -M $keymap "^[b" dirhistory_zle_dirhistory_back ;;        # ghostty
  iTerm.app)
    bindkey -M $keymap "^[^[[D" dirhistory_zle_dirhistory_back
    bindkey -M $keymap "^[b" dirhistory_zle_dirhistory_back
    ;;
  esac

  if (( ${+terminfo[kcub1]} )); then
    bindkey -M $keymap "^[${terminfo[kcub1]}" dirhistory_zle_dirhistory_back  # urxvt
  fi

  # dirhistory_future
  bindkey -M $keymap "\e[3C" dirhistory_zle_dirhistory_future    # xterm in normal mode
  bindkey -M $keymap "\e[1;3C" dirhistory_zle_dirhistory_future  # xterm in normal mode
  bindkey -M $keymap "\e\e[C" dirhistory_zle_dirhistory_future   # Putty
  bindkey -M $keymap "\eO3C" dirhistory_zle_dirhistory_future    # GNU screen

  case "$TERM_PROGRAM" in
  Apple_Terminal) bindkey -M $keymap "^[f" dirhistory_zle_dirhistory_future ;; # Terminal.app
  ghostty) bindkey -M $keymap "^[f" dirhistory_zle_dirhistory_future ;;        # ghostty
  iTerm.app)
    bindkey -M $keymap "^[^[[C" dirhistory_zle_dirhistory_future
    bindkey -M $keymap "^[f" dirhistory_zle_dirhistory_future
    ;;
  esac

  if (( ${+terminfo[kcuf1]} )); then
    bindkey -M $keymap "^[${terminfo[kcuf1]}" dirhistory_zle_dirhistory_future # urxvt
  fi
done

#
# HIERARCHY Implemented in this section, in case someone wants to split it to another plugin if it clashes bindings
#

# Move up in hierarchy
function dirhistory_up() {
  cd .. || return 1
}

# Move down in hierarchy
function dirhistory_down() {
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | sort -n | head -n 1)" || return 1
}


# Bind keys to hierarchy navigation
function dirhistory_zle_dirhistory_up() {
  zle .kill-buffer   # Erase current line in buffer
  dirhistory_up
  zle .accept-line
}

function dirhistory_zle_dirhistory_down() {
  zle .kill-buffer   # Erase current line in buffer
  dirhistory_down
  zle .accept-line
}

zle -N dirhistory_zle_dirhistory_up
zle -N dirhistory_zle_dirhistory_down

for keymap in emacs vicmd viins; do
  # dirhistory_up
  bindkey -M $keymap "\e[3A" dirhistory_zle_dirhistory_up    # xterm in normal mode
  bindkey -M $keymap "\e[1;3A" dirhistory_zle_dirhistory_up  # xterm in normal mode
  bindkey -M $keymap "\e\e[A" dirhistory_zle_dirhistory_up   # Putty
  bindkey -M $keymap "\eO3A" dirhistory_zle_dirhistory_up    # GNU screen

  case "$TERM_PROGRAM" in
  Apple_Terminal) bindkey -M $keymap "^[[A" dirhistory_zle_dirhistory_up ;;  # Terminal.app
  iTerm.app) bindkey -M $keymap "^[^[[A" dirhistory_zle_dirhistory_up ;;     # iTerm2
  ghostty) bindkey -M $keymap "^[[1;3A" dirhistory_zle_dirhistory_up ;;      # ghostty
  esac

  if (( ${+terminfo[kcuu1]} )); then
    bindkey -M $keymap "^[${terminfo[kcuu1]}" dirhistory_zle_dirhistory_up # urxvt
  fi

  # dirhistory_down
  bindkey -M $keymap "\e[3B" dirhistory_zle_dirhistory_down    # xterm in normal mode
  bindkey -M $keymap "\e[1;3B" dirhistory_zle_dirhistory_down  # xterm in normal mode
  bindkey -M $keymap "\e\e[B" dirhistory_zle_dirhistory_down   # Putty
  bindkey -M $keymap "\eO3B" dirhistory_zle_dirhistory_down    # GNU screen

  case "$TERM_PROGRAM" in
  Apple_Terminal) bindkey -M $keymap "^[[B" dirhistory_zle_dirhistory_down ;;  # Terminal.app
  iTerm.app) bindkey -M $keymap "^[^[[B" dirhistory_zle_dirhistory_down ;;     # iTerm2
  ghostty) bindkey -M $keymap "^[[1;3B" dirhistory_zle_dirhistory_down ;;      # ghostty
  esac

  if (( ${+terminfo[kcud1]} )); then
    bindkey -M $keymap "^[${terminfo[kcud1]}" dirhistory_zle_dirhistory_down # urxvt
  fi
done

unset keymap
#<<<}}}

