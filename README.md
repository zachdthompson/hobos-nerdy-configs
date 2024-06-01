# Hobo's Nerdy Configs
.configs for programs I use cross platform, like Neovim and Alacritty. I am using GNU stow to make symlinks to make managing these files easier.

## Overall Dependencies
I am using homebrew at the moment, for two major reasons: 
* This aligns config between my MacOS and Fedora boxes
* Fedora 40's NPM for Neovim comes with a bunch of crap in it. 

If you dont like homebrew, idk man. Its my repo. 

```bash
brew install stow
mkdir ~/dotfiles
cd ~/dotfiles
```
Copy all the configs into the dotfiles folder that you want to keep track of.

*IMPORTANT*
Make sure the file path matches EXACTLY as it would look in your home directory. Here is an example layout:

```
dotfiles
├── .config
│   ├── alacritty
│   │   ├── alacritty.toml

```
When stow is used, it will put the files right where it needs in ```.config```.

## Neovim Dependencies
```bash
brew install neovim
```
## ZSH Dependencies
```bash
brew install fzf
brew install bat
brew install eza
brew install tldr
brew install thefuck
brew install zoxide
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

# Note

I followed a tutorial to setup my Neovim, so shout out to this video as credit:
[Josean Martinez](https://www.youtube.com/watch?v=6pAG3BHurdM)
TBH I stole most of this from him. Go check him out