# Packages

`setup.sh` installs these. Every config feature-detects, so a missing package
only removes that feature.

| set | dnf / rpm-ostree | pacman (Arch, CachyOS) | apt |
|---|---|---|---|
| core | stow git tmux vim-enhanced bat eza zoxide fzf ripgrep fd-find unzip | stow git tmux vim bat eza zoxide fzf ripgrep fd unzip | stow git tmux vim bat eza zoxide fzf ripgrep fd-find unzip |
| desktop | zsh fish terminator fastfetch wl-clipboard xclip | same | same |
| nvim | neovim | neovim | neovim |
| `--extras` | zsh plugins; starship + lazygit via COPR `atim/*` | starship lazygit zsh plugins | zsh plugins only |

Notes:
- Debian/Ubuntu: `bat` installs as `batcat`; the shells alias it. Older releases lack `eza` — skipped, falls back to `ls`.
- RHEL/Rocky: most CLI tools need EPEL. Without it they're skipped.
- Debian 12 / Ubuntu 22.04 ship nvim < 0.10 → basic mode. Use an official
  release tarball unpacked into `~/.local` instead.

## LSP servers (nvim)

Not installed by setup.sh — install what you use; nvim enables any it finds on PATH.

| server | binary | typical install |
|---|---|---|
| gopls | `gopls` | `go install golang.org/x/tools/gopls@latest` |
| lua_ls | `lua-language-server` | distro package (Arch, Fedora) or GitHub release tarball |
| pyright | `pyright-langserver` | `npm i -g pyright` or `pipx install pyright` |
| ruff | `ruff` | distro package or `pipx install ruff` |
| bashls | `bash-language-server` | `npm i -g bash-language-server` (+ shellcheck) |
| terraformls | `terraform-ls` | HashiCorp repo (same one that ships terraform) |
| yamlls | `yaml-language-server` | `npm i -g yaml-language-server` |
| jsonls | `vscode-json-language-server` | `npm i -g vscode-langservers-extracted` |
| marksman | `marksman` | GitHub release binary |
| clangd | `clangd` | `clang-tools-extra` / `clang` |
| rust_analyzer | `rust-analyzer` | `rustup component add rust-analyzer` |

For offline hosts: most of these are single static binaries (gopls, terraform-ls,
marksman, rust-analyzer, ruff). Copy them into `~/.local/bin`.

To add a server: create `nvim/.config/nvim/lsp/<name>.lua` returning
`{ cmd, filetypes, root_markers, settings }` and add the name to the list in
`lua/hobo/lsp.lua`.
