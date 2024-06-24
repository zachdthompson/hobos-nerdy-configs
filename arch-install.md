# Simple Arch Install

This gives quick setup for Arch specific platforms. This should work for most Linux distros, just replace pacman with whatever your package manager of choice is.

## Install Dependent Packages

```bash
sudo pacman -S zsh stow neovim fzf bat eza tldr thefuck npm zoxide alacritty tmux lazygit ttf-meslo-nerd
yay -Sy ttf-meslo-nerd-font-powerlevel10k zsh-theme-powerlevel10k-git
```

## Create and Import Dependent Files

### Theme dependencies

```bash
cd ~
git clone https://github.com/junegunn/fzf-git.sh.git
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
cd ~
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

### Import the dotfiles configs

This command imports the configs, and will stow them right away. Be sure the first steps are done or this will break zsh!

```bash
mkdir ~/dotfiles
git clone git@github.com:zachdthompson/hobos-nerdy-configs.git ~/dotfiles
cd ~/dotfiles
stow --adopt .
```

### Change default shell

```bash
chsh -s /bin/zsh
```

### Configure TMUX

Enter into a tmux session:

```brew
tmux
```

Press <Ctl>b + I (Control-b, then CAPITAL I).
Plugins should now install.
