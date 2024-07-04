# Simple Fedora Install

This gives quick setup for Fedora.

## Install Dependent Packages

### Install Needed Packages

```bash
sudo dnf fish stow neovim fzf bat tldr thefuck npm kitty tmux go unzip xclip fastfetch spectacle solaar
```

### Install COPR Packages

Note that COPR packages are not official packages and should be treated with care.

#### Lazygit

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

#### Starship

```bash
sudo dnf copr enable atim/starship -y
sudo dnf install starship
```

#### Fisher

```bash
fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
```

### Fisher Packages Needed

```bash
fisher install plttn/fish-eza
```

## Create and Import Dependent Files

### Fonts

For some unknown reason, you cannot just install fonts with `dnf`...

Navigate to [the official nerd-fonts page](https://www.nerdfonts.com/) and download

- [DevIcons](http://vorillaz.github.io/devicons/#/main)
- [MesloLG Nerd Font](https://www.nerdfonts.com/font-downloads)

You will then need to extract and install these. The easiest way is to just open the font manager in KDE and drag them over. Install them for the SYSTEM!

### Theme dependencies

```bash
cd ~
git clone https://github.com/junegunn/fzf-git.sh.git
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
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

I am now using fish instead of zsh as my shell

```bash
chsh -s /bin/fish
```

If you log out and log back in and the default shell has not changed, try this:

```bash
pkill -KILL -u <your user>
```

This will kill all your sessions. Log back in and it should be running again.

### Configure TMUX

Enter into a tmux session:

```brew
tmux
```

Press `<Ctl>b + I` (Control-b, then CAPITAL I).
Plugins should now install.

## Post Install

### Generate SSH Keys

```bash
ssh-keygen /home/hobo/.ssh/hobo
ssh-keygen /home/hobo/.ssh/github
```

### Change Upstream to SSH

I made the dotfiles pull via https so that I could do so without an SSH key. After an SSH key has been added, run the following command

```bash
git remote set-url origin git@github.com:zachdthompson/hobos-nerdy-configs.git
```

### Setup FirewallD

We will not be using UFW on Fedora. My TODO is to setup FirewallD configs.

# Post Install Programs

Optional programs that I use on a daily basis.

### Enable Non-Open Source

In order to install our programs, we will need non free repos.

```bash
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### Install the Programs

```bash
sudo dnf install discord steam flatpak
yay -S slack-desktop
```

## Setting up Bottles

```bash
sudo dnf install bottles
```

After bottles loads, select a new app and install Battle.net from the predefined list.
Be sure to go in to dependencies and select `allfonts` to be installed.

# TODOs

- Create a folder where git clones can go in that arent just spammed in the home folder.
  - This means I will need to update all the file locations in all configs, but it will be worth it.
- Create a package list that explains what each package is and why its needed, for future cleanup/use
