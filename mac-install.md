# Simple MacOS Installer

This will quickly walk through all my settings for MacOS and get you up and running.

## Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Install Dependent Packages

```bash
brew install fish stow neovim fzf bat tldr thefuck npm kitty tmux lazygit starship unzip xclip fisher fastfetch zoxide font-monaspace-nerd-font font-noto-sans-symbols-2 eza
```

These packages are needed for the rest of the configs to function properly.

### Change Default Shell

I had to change my shell in a weird way due to fish not being a standard shell.

```bash
echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
sudo chsh -s /opt/homebrew/bin/fish "$USER"
```

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

### Configure TMUX

Enter into a tmux session:

```brew
tmux
```

Press <Ctl>b + I (Control-b, then CAPITAL I).
Plugins should now install.
