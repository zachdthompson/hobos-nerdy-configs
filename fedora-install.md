# Simple Fedora Install

This gives quick setup for Fedora.

## Important Updates:

I have completely removed most of my configuration down to as little as possible. I will likely write a blog post on this at some point, but the TL;DR is that most of what I have I cannot use in an enterprise environment at work. I cant use fish, I use vim because lazy-nvim isnt feasible, etc. I cant use tmux because I cant be pushing my personal config to enterprise machines. 

Fish > Bash
Nvim > vim
tmux > terminator
(just to list a few changes)

Despite all these changes, I feel like my experience is 95% of the way there to what it was before. 

### Final Notes Before Install

A big push to my configs being minimal is to limit the amount of weird third party repos I use. I only use the fedora non-free and the official microsoft repository for VS code. Third party repos have come under a lot of fire recently, and until a better solution is figured out for ensuring non-malicious code uploads, I will be going back to basics.

## Install Dependent Packages

### Install Needed Packages

### Built in Packages
```bash
sudo dnf install stow bat unzip xclip fastfetch terminator
```

### Install Limited 3rd Party Packages

Note that any 3rd party packages are not official packages and should be treated with care.

### NonFree

#### Install the NonFree Repo
```bash
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
#### Install NonFree packages

```bash
sudo dnf install discord steam flatpak
```

#### Lazygit

**THIS IS COPR. I think its harmless, but do your own research.**

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

#### Starship

**THIS IS COPR. I think its harmless, but do your own research.**

```bash
sudo dnf copr enable atim/starship -y
sudo dnf install starship
```

## Create and Import Dependent Files

### Meslo LGL Nerd Font Mono

Feel free to use your own, I like this one.

```bash
mkdir -p ~/.local/share/fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
unzip Meslo.zip -d ~/.local/share/fonts/
fc-cache -fv
rm Meslo.zip
```

### Theme dependencies

```bash
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
```

## Import the dotfiles configs

This command imports the configs, and will stow them right away. Be sure the first steps are done or this will break zsh!

```bash
mkdir ~/dotfiles
git clone https://github.com/zachdthompson/hobos-nerdy-configs.git ~/dotfiles
cd ~/dotfiles
stow --adopt .
```

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


# TODOs

- Create a folder where git clones can go in that arent just spammed in the home folder.
  - This means I will need to update all the file locations in all configs, but it will be worth it.
- Create a package list that explains what each package is and why its needed, for future cleanup/use
