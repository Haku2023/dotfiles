#!/bin/bash

# create the .config folder
mkdir -p "$HOME/.config"
folders=("nvim" "wezterm")
files=("zshrc")
for folder in "${folders[@]}";do
  # check whether files exist
  if [ -d "$HOME/.config/${folder}" ] || [ -h "$HOME/.config/${folder}" ]; then
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

	ln -sf "$HOME/dotfiles/${folder}" "$HOME/.config"
	echo "->Link ${folder} Success"
done

for file in "${files[@]}";do
  if [ -f "$HOME/.${file}" ] || [ -h  "$HOME/.${file}" ]; then
    answer=""
    until [ "${answer}" = 'y' ] || [ "${answer}" = 'n' ]; do
      read -r -p "$HOME/.${file} exist, whether remove? y/n " answer
    done
    if [ "${answer}" = 'y' ]; then
      echo "->Remove $HOME/.${file}"
    elif [ "${answer}" = 'n' ]; then
      echo "->choose n, not install \"$HOME/.${file}\", bless you work fine"
      continue
    fi
  fi
  os=""
  until [ -f "$HOME/dotfiles/rcfiles/${file}_${os}" ]; do
    read -r -p "Choose your device sys for ${file}: mac,linux... " os
  done
    ln -sf "$HOME/dotfiles/rcfiles/${file}_${os}" "$HOME/.${file}"
    echo "->Link ${file}_${os} Success"
done


