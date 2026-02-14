# refer oh-my-zsh
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias md='mkdir -p'
alias rd=rmdir
alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
alias grep="grep --color=auto"
#
#
alias history="omz_history -f"
alias h='history'
alias hl='history | less'
alias hs='history | grep'
alias hsi='history | grep -i'
alias zrc="nvim ~/.zshrc"
alias sou="exec zsh"
alias nlua="nvim ~/.config/nvim/lua/haku/core/options.lua"
alias pl="pdflatex"
# mac
alias wlua="nvim ~/.config/wezterm/wezterm.lua"
alias vi="nvim"
alias ls="eza --icons=always"
alias lsn="eza --icons=always -l -snew"
alias vu="vi ~/Documents/Projects/haku_git/haku_tools_linux/useful_linux_commands.md"
alias vc="vi ~/haku_git/wezterm-nvim_setup/zsh_setup.md"
alias hwlua="vi ~/haku_git/wezterm-nvim_setup/wezterm.lua"
alias cd="z"
# check which port is on listening
alias hlisten="echo '(head -n 1 && grep LISTEN) <<< sudo lsof -i -P -n ';(head -n 1 && grep LISTEN) <<< \`sudo lsof -i -P -n\`"
if [[ "$(uname)" == "Darwin" ]];then
  alias rm="\grm --preserve-root -I"
  alias haku25_old="cd '/Users/bai.haodong/Documents/Doctor_Life/G-学会/14. English Thesis/graphs'"
  alias haku25="cd '/Users/bai.haodong/Documents/Doctor_Life/The_Way_To/2025_Projects/H-Fresh'; vi "
  alias haku26="cd '/Users/bai.haodong/Documents/Doctor_Life/The_Way_To/2026_Projects';ls "
  alias rsync_homepage="echo 'rsync -avz --progress ./* \"85:/srv/Taisui_WebSite/Tests/\"';rsync -avz --progress ./* "85:/srv/Taisui_WebSite/Tests/""
  alias rsync_src="rsync -avz --progress '73:/cygdrive/c/Users/baihaodong/Documents/2025Tasks/Thesis_ADE/Solution_T_ADE/src/*' /Users/bai.haodong/Documents/Doctor_Life/The_Way_To/2026_Projects/H-Fresh/src;echo 'rsync H-Fresh(73) completed!'"
  alias rsync_cip="echo 'rsync -avz --del --progress 73:~/Projects/Yodo_26/CIP/*';rsync -avz --del --progress '73:~/Projects/Yodo_26/CIP/*' /Users/bai.haodong/Documents/Doctor_Life/The_Way_To/2026_Projects/CIP;echo 'rsync CIP(73) completed!'"
  # alias rsync_cip="echo 'rsync -avz --del --progress 73:~/Projects/Yodo_26/CIP/*'; rsync -avz --progress '73:~/Projects/Yodo_26/CIP/*' /Users/bai.haodong/Documents/Doctor_Life/The_Way_To/2026_Projects/CIP"
  # life
  alias myLove="open https://meeting.tencent.com/p/9796730765\?pwd\=500012"
  alias japaneseCourse="open https://kyoto-u-edu.zoom.us/j/91423186918\?pwd\=alhtRnhlcUljVi84Z0hncjRZREtjZz09"
elif [[ "$(uname)" == "Linux" ]];then
  alias rm="rm --preserve-root -I"
  alias chmod="chmod --preserve-root"
fi

# git
#basic
alias gl='git pull'
alias gp='git push'
alias ga='git add'
alias gaa='git add --all'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstall='git stash --all'
alias gst='git status'
alias gstp='git stash pop'
alias gdup='git diff @{upstream}'

function gd() {
  if [[ "${1}" =~ ^[1-9]$ ]];then
    git diff @{${1}}
  else
    git diff "$@"
  fi
}
#<<<{{{
#
alias gpr='git pull --rebase'
alias gprv='git pull --rebase -v'
alias gpra='git pull --rebase --autostash'
alias gprav='git pull --rebase --autostash -v'
#
alias gpu='git push upstream'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grbd='git rebase $(git_develop_branch)'
alias grbm='git rebase $(git_main_branch)'
alias grbom='git rebase origin/$(git_main_branch)'
alias grbum='git rebase upstream/$(git_main_branch)'
alias grf='git reflog'
alias gr='git remote'
alias grv='git remote --verbose'
alias gra='git remote add'
alias grrm='git remote remove'
alias grmv='git remote rename'
alias grset='git remote set-url'
alias grup='git remote update'
alias grh='git reset'
alias gru='git reset --'
alias grhh='git reset --hard'
alias grhk='git reset --keep'
alias grhs='git reset --soft'
alias gpristine='git reset --hard && git clean --force -dfx'
alias gwipe='git reset --hard && git clean --force -df'
alias groh='git reset origin/$(git_current_branch) --hard'
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'
alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
alias grev='git revert'
alias greva='git revert --abort'
alias grevc='git revert --continue'
alias grm='git rm'
alias grmc='git rm --cached'
alias gcount='git shortlog --summary --numbered'
alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'
alias gstaa='git stash apply'
alias gstc='git stash clear'
# use the default stash push on git 2.13 and newer
alias gsts='git stash show --patch'
alias gss='git status --short'
alias gsb='git status --short --branch'
alias gsi='git submodule init'
alias gsu='git submodule update'
alias gsd='git svn dcommit'
alias git-svn-dcommit-push='git svn dcommit && git push github $(git_main_branch):svntrunk'
alias gsr='git svn rebase'
alias gsw='git switch'
alias gswc='git switch --create'
alias gswd='git switch $(git_develop_branch)'
alias gswm='git switch $(git_main_branch)'
alias gta='git tag --annotate'
alias gts='git tag --sign'
alias gtv='git tag | sort -V'
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
alias gwch='git log --patch --abbrev-commit --pretty=medium --raw'
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtmv='git worktree move'
alias gwtrm='git worktree remove'
alias gstu='gsta --include-untracked'
alias gtl='gtl(){ git tag --sort=-v:refname -n --list "${1}*" }; noglob gtl'
alias gk='\gitk --all --branches &!'
alias gke='\gitk --all $(git log --walk-reflogs --pretty=%h) &!'
#gca
alias gcam='git commit --all --message'
alias gcas='git commit --all --signoff'
alias gcasm='git commit --all --signoff --message'
alias gcs='git commit --gpg-sign'
alias gcss='git commit --gpg-sign --signoff'
alias gcssm='git commit --gpg-sign --signoff --message'
alias gcmsg='git commit --message'
alias gcsm='git commit --signoff --message'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gca!='git commit --verbose --all --amend'
alias gcan!='git commit --verbose --all --no-edit --amend'
alias gcans!='git commit --verbose --all --signoff --no-edit --amend'
alias gcann!='git commit --verbose --all --date=now --no-edit --amend'
alias gc!='git commit --verbose --amend'
alias gcn='git commit --verbose --no-edit'
alias gcn!='git commit --verbose --no-edit --amend'
alias gcf='git config --list'
alias gcfu='git commit --fixup'
alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'

# <<<}}}
#
