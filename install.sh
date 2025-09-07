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
      ln -sf "$HOME/dotfiles/${folder}" "$HOME/.config"
      echo "->Link Success"
    elif [ "${answer}" = 'n' ]; then
      echo "->choose n, stop installing, check the folder you want to install "
      exit 9
    fi
  fi

done

for file in "${files[@]}";do
  if [ -f "$HOME/.${file}" ] || [ -h  "$HOME/.${file}" ]; then
    answer=""
    until [ "${answer}" = 'y' ] || [ "${answer}" = 'n' ]; do
      read -r -p "$HOME/.${file} exist, whether remove? y/n " answer
    done
    if [ "${answer}" = 'y' ]; then
      echo "->Link with Remove $HOME/.${file}"
      ln -sf "$HOME/dotfiles/rcfiles/${file}" "$HOME/.${file}"
    elif [ "${answer}" = 'n' ]; then
      echo "->choose n, stop installing, check the rc file you want to install "
      exit 9
    fi
  fi
done


