#!/bin/bash

# create the .config folder
mkdir -p "$HOME/.config"
# mac / linux
## nvim, wezterm
folders=("nvim" "wezterm")
for folder in "${folders[@]}";do
  # check whether files exist
  if [ -d "$HOME/.config/${folder}" ]; then
    if [  -h "$HOME/.config/${folder}" ];then
      echo "${folder} is a symbolic folder"
    fi
    answer=""
    until [ "${answer}" = 'y' ] || [ "${answer}" = 'n' ]; do
      read -r -p "$HOME/.config/${folder} exist, whether remove? y/n " answer
    done
    if [ "${answer}" = 'y' ]; then
      echo "->Remove $HOME/.config/${folder}"
      rm -rf "$HOME/.config/${folder}"
    elif [ "${answer}" = 'n' ]; then
      echo "->choose n, not install \"$HOME/.config/${folder}\", bless you work fine. "
      continue
    fi
  fi

	ln -sf "$DOTFILES/${folder}" "$HOME/.config"
	echo "->Link ${folder} Success"
done
 
until [ "${answer}" = 'y' ] || [ "${answer}" = 'n' ]; do
  read -r -p "=> Next, We will link the zsh, qutebrowser, if you are not read, say n" answer
done
if [  "${answer}" = 'n' ];then
  echo "=> End 2: Only install Wezterm and Nvim"
  exit 2
fi

## zsh
ln -sf "$DOTFILES/zsh/zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
echo "->Link zshenv,zshrc Success"
## qutebrowser
if [[ "$(uname)" == "Linux" ]]; then
  ln -sf "$DOTFILES/qutebrowser" "$HOME/.config/qutebrowser"
elif [[ "$(uname)" == "Darwin" ]]; then
  ln -sf "$DOTFILES/qutebrowser" "$HOME/.qutebrowser/qutebrowser"
fi
echo "->Link qutebrowser Success"

# files=("zshrc")
# for file in "${files[@]}";do
#   if [ -f "$HOME/.${file}" ] || [ -h  "$HOME/.${file}" ]; then
#     answer=""
#     until [ "${answer}" = 'y' ] || [ "${answer}" = 'n' ]; do
#       read -r -p "$HOME/.${file} exist, whether remove? y/n " answer
#     done
#     if [ "${answer}" = 'y' ]; then
#       echo "->Remove $HOME/.${file}"
#     elif [ "${answer}" = 'n' ]; then
#       echo "->choose n, not install \"$HOME/.${file}\", bless you work fine"
#       continue
#     fi
#   fi
#   os=""
#   until [ -f "$HOME/dotfiles/rcfiles/${file}_${os}" ]; do
#     read -r -p "Choose your device sys for ${file}: mac,linux... " os
#   done
#     ln -sf "$HOME/dotfiles/rcfiles/${file}_${os}" "$HOME/.${file}"
#     echo "->Link ${file}_${os} Success"
# done


