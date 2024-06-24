# Simple Arch Install

This gives quick setup for Arch specific platforms. This should work for most Linux distros, just replace pacman with whatever your package manager of choice is.

## Install Dependent Packages

```bash
sudo pacman -S zsh stow neovim fzf bat eza tldr thefuck npm zoxide alacritty tmux lazygit ttf-meslo-nerd ufw
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
git clone https://github.com/zachdthompson/hobos-nerdy-configs.git ~/dotfiles
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

Press `<Ctl>b + I` (Control-b, then CAPITAL I).
Plugins should now install.

## Setting up UFW

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.2.0.0/16 to 22
sudo ufw allow from 172.30.69.2 to 22
sudo ufw enable
```

# Post Install Programs

Optional programs that I use on a daily basis.

```bash
sudo pacman -S discord flatpak steam
yay -S slack-desktop
```

## Setting up Bottles

```bash
flatpak install bottles
```

After bottles loads, select a new app and install Battle.net from the predefined list.
Be sure to go in to dependencies and select `allfonts` to be installed.