## old settings
plugins=(git zsh-vi-mode zsh-autosuggestions fast-syntax-highlighting  web-search history dirhistory )

## new settings
>`mkdir ~/.zsh-plugins`
1. zsh-vi-mode
```zsh
# Arch Linux
yay -S zsh-vi-mode
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
# Brew
brew install zsh-vi-mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
# Manually
git clone https://github.com/jeffreytse/zsh-vi-mode.git $HOME/.zsh-plugins/zsh-vi-mode
source $HOME/.zsh-plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
```

2. zsh-autosuggestions
```zsh
# Arch Linux
yay -S zsh-autosuggestions
source /usr
# Brew
brew install zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# Manually
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh-plugins/zsh-autosuggestions
source $HOME/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
```

3. fast-syntax-highlighting
```zsh
# Manually
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting $HOME/.zsh-plugins/fast-syntax-highlighting
source $HOME/.zsh-plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

```

4. powerlevel10k
```zsh
# Maually
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.zsh-plugins/powerlevel10k
source $HOME/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme

```
