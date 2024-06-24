# Simple MacOS Installer

This will quickly walk through all my settings for MacOS and get you up and running.

I prefer to use iTerm2, so the Alacritty installer steps are not included here.

[Download iTerm2](https://iterm2.com/)

## Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Install Dependent Packages

```bash
brew install zsh npm stow neovim fzf bat cat eza tldr thefuck zoxide lazygit
brew install tmux font-monaspace-nerd-font font-noto-sans-symbols-2
brew install bash bc coreutils gawk gh glab gsed jq nowplaying-cli
```

Most of those packages on the last line should error out as they are already installed, however on my main Mac I was missing a few, so I included all of them.

## Install Themes and Plugins

```bash
cd ~
git clone https://github.com/junegunn/fzf-git.sh.git
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
```

## Download and Stow Configs

```bash
mkdir ~/dotfiles
git clone https://github.com/zachdthompson/hobos-nerdy-configs.git ~/dotfiles
cd ~/dotfiles
stow --adopt .
```

## Final Setup

### Change Default Shell

```brew
chsh -s /bin/zsh
```

### Configure TMUX

Enter into a tmux session:

```brew
tmux
```

Press <Ctl>b + I (Control-b, then CAPITAL I).
Plugins should now install.
