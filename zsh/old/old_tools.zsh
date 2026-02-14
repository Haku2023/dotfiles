# deprecated
>>>>>>>>>>>>>>>{{{
alias hnlua="vi ~/haku_git/haku_tools_linux/zsh_setup/config/nvim/init.lua"

# Function  
# go to the paper 2013 
H-Fresh(){
open /Users/bai.haodong/Documents/大学院ー博士/＊博士課題について/3.\ 論文/H-Fresh
}
# go to the folder 2013
2013(){
open /Users/bai.haodong/Documents/大学院ー博士/＊博士課題について/3.\ 論文/Experiment/2013_Journal\ of\ offshore\ mechanics\ and\ Arctic\ engineering_Experimental\ Investigation\ of\ Tsunami\ Bore\ Forces\ on\ Vertical\ Walls.pdf
}
# o -1 -2 -3
o(){
case $1 in 
    -1)
    printf "%s\n" "$(alias oCalendar)" "$(alias oFf)" "$(alias oNotes)" "$(alias oMail)" "$(alias oMaps)" "$(alias oSs)" "$(alias oSafari)" "$(alias oFirefox)"
    ;;
    -2)
    printf '%s\n' 'word=Microsoft Word' 'ppt=Microsoft Powerpoint' 'preview=Mac Preview' 'keynote=Mac Keynote' 'mrd=Microsoft Remote Desktop'
    ;;
    -3)
    printf '%s\n' 'work on/off = start/finish mail'
    ;;
    *)
    echo "o: unknown key $1"
    return 1
    ;;
esac
}
complete -W "-1 -2 -3" o

# Apple scripts
create_focus_browser(){
    local -A browser_dict=([chrome]="Google Chrome" [safari]="Safari")
    local app_name="${browser_dict[$1]}"
    local func_name=$1
    local -A script_dict=([chrome]="set active tab index of window w to t" [safari]="set current tab of window w to tab t of window w")

    eval "$func_name(){
        case \$1 in
            kyotoportal)
                local arg=student.iimc.kyoto
            ;;
                mail163)
                local arg='mail.163.com'
            ;;
                gpt)
                local arg='chat.openai.com'
            ;;
                dict)
                local arg='dict.hjenglish.com'
            ;;
                Gdrive)
                local arg='drive.google.com'
            ;;
                kaiyou)
                local arg='committees.jsce.or.jp'
            ;;
                kaigan)
                local arg='coastal.jp'
            ;;   
                *)
                echo "${app_name}: unknown key \$1"
                return 1
            ;;
            esac
        osascript <<EOF
tell application \"$app_name\"
    activate
    repeat with w from 1 to count windows
        set theTabs to tabs of window w
        repeat with t from 1 to count theTabs
            if URL of tab t of window w contains \"\$arg\" then
                ${script_dict[$1]}
                return
            end if
        end repeat
    end repeat
end tell
EOF
        
}"
complete -W "kyotoportal mail163 gpt dict Gdrive kaiyou kaigan" $func_name
}



# Mail work funtion
work (){
case $1 in 
on)
    local arg=勤務開始報告
;;
off)
    local arg=勤務終了報告
;;
*)
    echo "work: unknow key $1"
    return
;;
esac
~/appleScripts/mailWork_v2.sh $arg}
complete -W "on off" work




# for create focus browser
create_focus_browser chrome
create_focus_browser safari

#--------------------------------#
# Windows Remote Desktop Function
mrd() {
    ~/appleScripts/windows_click.sh $1 "Microsoft Remote Desktop"}
## completion
mrds(){
    ip_addresses=$(~/appleScripts/windows_find.sh "Microsoft Remote Desktop")
    items=()
    # Split the output into an array
    items=(${(@s:|:)ip_addresses})
    items+=("Connection Center")
    for i in "${items[@]}";do
        echo $i
    done
}
complete -F mrds mrd
#--------------------------------#
#--------------------------------#
# Preview Function
preview() {
    ~/appleScripts/windows_click.sh $1 "Preview"}
## completion
preview_s(){
    ip_addresses=$(~/appleScripts/windows_find.sh "Preview")
    items=()
    # Split the output into an array
    items=(${(@s:|:)ip_addresses})
    for i in "${items[@]}";do
        echo $i
    done
}
complete -F preview_s preview
#--------------------------------#
#--------------------------------#
# Word Function
word() {
    ~/appleScripts/windows_click.sh $1 "Microsoft Word"}
## completion
word_s(){
    ip_addresses=$(~/appleScripts/windows_find.sh "Microsoft Word")
    items=()
    # Split the output into an array
    items=(${(@s:|:)ip_addresses})
    for i in "${items[@]}";do
        echo $i
    done
}
complete -F word_s word
#--------------------------------#
#--------------------------------#
# Keynote Function
keynote() {
    ~/appleScripts/windows_click.sh $1 "Keynote"}
## completion
keynote_s(){
    ip_addresses=$(~/appleScripts/windows_find.sh "Keynote")
    items=()
    # Split the output into an array
    items=(${(@s:|:)ip_addresses})
    for i in "${items[@]}";do
        echo $i
    done
}
complete -F keynote_s keynote
#--------------------------------#

# add CC PATH
#export "PATH=/usr/local/opt/llvm/bin/clang:$PATH"
#ln -s /usr/local/opt/llvm/bin/clang /usr/local/bin/clang

alias ssh_wsl="echo \"On CMD/PS adm: \n1.Reset Interface: \nnetsh interface portproxy reset \n2.Connect Interface: \nnetsh interface portproxy add v4tov4 listenaddress=10.244.7.73 listenport=22 connectaddress=172.26.189.101 connectport=22\n3.Show Interface: \nnetsh interface portproxy show all \""
# <<<<<<<<<<<<<<<}}}
#
# mac air setting
# >>>>>>>>>>>>>>>{{{
if [[ "$(uname)" == "Darwin" ]];then
wsh () {
  wezterm cli spawn --domain-name "SSH:$1"
}
complete -W "73 117 109" wsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# haku alias # mac air setting
alias thesis='cd "/Users/bai.haodong/Documents/大学院ー博士/G-学会"'
alias c="cd ~/Documents/"
alias oCalendar="open -a Calendar"
alias oFf="open -a Freeform"
alias oFirefox='open -a Firefox'
alias oNotes="open -a Notes"
alias oMail="open -a Mail"
alias oMaps="open -a Maps"
alias oSs='open -a "System Settings"'
alias oSafari='open -a Safari'

# unzip for css
alias csunzip="unzip ~/Downloads/\$(ls -t ~/Downloads | head -n1) -d ~/Documents/Code_Cluster/Html-Css-Javascript/Web_Development_Project ; open -a 'Visual Studio Code'"
# This file gives the useful shortcuts for applications used in GUI
fi
# <<<<<<<<<<<<<<<}}}
#
# zsh commands
# >>>>>>>>>>>>>>>>{{{
# use vim in cmd# 
bindkey -v
bindkey -M viins 'kk' vi-cmd-mode
bindkey -M viins 'jj' vi-cmd-mode
bindkey '^B' backward-char
bindkey '^F' forward-char
bindkey -M vicmd '^C' _ins_after_break
bindkey -M viins '^C' _ins_after_break   # optional: same behavior if you hit ^C in insert
to use ls -- ^a / rm -- ^a
# <<<<<<<<<<<<<<<<# }}}
