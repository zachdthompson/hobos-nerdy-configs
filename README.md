# Hobo's Nerdy Configs

.configs for programs I use cross platform, like Neovim and Alacritty. I am using GNU stow to make symlinks to make managing these files easier.

## Quick Installers

- [MacOS](mac-install.md)
- [Arch Linux](arch-install.md)
- [Fedora 40](fedora-install.md)

Note that the Arch Install should work for most distros, I just use arch, so its tuned to that.

![CurrentLook](CurrentLook.png)

# Each Package Explained

## Overall Dependencies

The config is shown using Homebrew for MacOS. These calls can be replaced with your system package manager calls.

```bash
brew install npm
```

### Arch Specific

xclip is needed in order for neovim to interact with your clipboard.

```bash
sudo pacman -S xclip
```

I heavily reccomend you switch your CAPS key to be an additional ALT key. It will be better on your hands.
This can be done in the keybind settings of most OS', or on custom firmware settings.

## Installing/Configuring Stow

```bash
brew install stow
mkdir ~/dotfiles
cd ~/dotfiles
```

Copy all the configs into the dotfiles folder that you want to keep track of.

**IMPORTANT**

Make sure the file path matches EXACTLY as it would look in your home directory. Here is an example layout:

```
dotfiles
├── .config
│   ├── alacritty
│   │   ├── alacritty.toml

```

When stow is used, it will put the files right where it needs in `.config`.
Once you have copied your configs, you can run the following to create the symlinks:

```bash
sudo stow --adopt .
```

If you go back to any file you stowed, its now a symlink to this copy.

## Neovim Dependencies

```bash
brew install neovim
```

## ZSH Dependencies

```bash
brew install fzf
brew install bat
brew install eza
brew install tldc
brew install thefuck
brew install zoxide
```

## fzf Dependencies

```bash
git clone https://github.com/junegunn/fzf-git.sh.git
```

## bat Dependencies

```bash
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
```

## Alacritty Dependencies

```bash
brew install alacritty
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

## Lazygit

```bash
brew install lazygit
```

Add SSH key to agent

```bash
eval $(ssh-agent)
ssh-add ~/.ssh/<your github key>
```

## Tmux

```bash
brew install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
brew install --cask font-monaspace-nerd-font font-noto-sans-symbols-2
brew install bash bc coreutils gawk gh glab gsed jq nowplaying-cli
```

Not having those last two lines took me like 4 hours to debug...

# Note

I followed a tutorial to setup my Neovim, so shout out to this video as credit:
[Josean Martinez](https://www.youtube.com/watch?v=6pAG3BHurdM)
TBH I stole most of this from him. Go check him out
