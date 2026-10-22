# hobo's nerdy configs

Portable dotfiles built around one rule: **nothing fetches anything at runtime.**
No plugin managers, no TPM, no mason, no `curl | sh` in a shell rc. Third-party
code is vendored into the repo as plain files, so a copy of this directory works
the same on an air-gapped box as on a laptop.

## Layout

```
shell/     bash, tmux, vim, git, ssh, tssh + xpanes     → every host
desktop/   fish, zsh, starship, terminator, fastfetch   → personal machines
nvim/      neovim config + vendored plugins             → anywhere nvim ≥ 0.10 exists
archive/   retired configs, never stowed
docs/      keybinds.md, packages.md
vendor.sh  refresh vendored code (personal machine only)
```

Each top-level dir is a GNU Stow package. `setup.sh` links them into `$HOME`;
the repo can live anywhere.

## Install

```bash
./setup.sh                              # interactive
./setup.sh --tier desktop --extras      # personal machine, everything
./setup.sh --tier shell --nvim --yes    # server/work box, no prompts
./setup.sh --stow-only --tier shell     # link only, no sudo
./setup.sh --dry-run --tier desktop     # preview
```

Detects dnf, rpm-ostree (Bazzite/Silverblue — checked before dnf), pacman
(Arch/CachyOS) and apt. Anything that would be overwritten is moved to
`~/.dotfiles-backup/<timestamp>/` first. Re-running is safe.

Stow runs with `--no-folding` so `~/.ssh`, `~/.config/fish` etc. stay real
directories — keys and runtime files never land in the repo. The one exception
is `~/.config/nvim`, which is linked whole (it's entirely repo-owned).

## Machine-local overrides (never committed)

| file | for |
|---|---|
| `~/.gitconfig.local` | git name/email (setup.sh offers to create it) |
| `~/.bashrc.local`, `~/.bashrc.d/*.sh` | bash |
| `~/.zshrc.local` | zsh |
| `~/.config/fish/conf.d/*.fish` | fish |
| `~/.tmux.local.conf` | tmux |
| `~/.ssh/config.d/*.conf` | extra ssh hosts |
| `~/.config/nvim/lua/local.lua` | nvim (see `local.lua.example`) |
| `~/.config/tssh/groups/<name>` | host groups for `tssh @name` |

## tmux + tssh (cssh replacement)

```bash
tssh host1 host2 host3        # one pane per host, broadcast on
tssh @cp                      # hosts from ~/.config/tssh/groups/cp
tssh -J bastion @cp @workers  # via ProxyJump — run it locally, not on the jumpbox
tssh -d -l admin web{1..4}    # start with broadcast off, remote user
```

`prefix e` toggles broadcast — borders go red and the bar shows **BROADCAST**.
Turn it off, type on one host, turn it back on: same as clicking into one cssh
terminal.

**Nested tmux** (local tmux → ssh → remote tmux): press **F12** to suspend the
local tmux so every key goes to the inner one; the bar shows **NESTED**. F12
again to come back. Or prefix twice (`C-b C-b`) for a one-off.

Full key list: [docs/keybinds.md](docs/keybinds.md).

## Neovim

Plain native packages under `nvim/.config/nvim/pack/vendor/opt/`, loaded with
`:packadd`. What replaces what:

| before (lazy.nvim) | now |
|---|---|
| telescope + fzf-native | mini.pick + mini.extra |
| which-key | mini.clue (press `<Space>` and wait) + `<Space>fk` |
| nvim-tree | nvim-tree (same keys) |
| nvim-cmp | mini.completion |
| mason + lspconfig | native `vim.lsp.config` — enables servers found on PATH |
| lualine / bufferline / alpha | mini.statusline / tabline / starter |
| gitsigns / lazygit.nvim | mini.diff + mini.git / floating lazygit |
| autopairs, surround, comment | mini.pairs, mini.surround (ys/ds/cs), built-in `gc` |
| auto-session, maximizer | mini.sessions, built-in function |
| treesitter | built-in parsers only (lua, vim, c, markdown, …) |

Version support: **≥ 0.11** full · **0.10** full (LSP via shim) · **< 0.10**
options + keymaps only, netrw tree. On a host with old nvim, drop an official
release tarball into `~/.local` — it's a static binary, no install needed.

No Nerd Font on a box? `export NVIM_ASCII=1`.

LSP servers are not bundled — install the ones you use (see
[docs/packages.md](docs/packages.md)) and they attach automatically.
`:checkhealth vim.lsp` shows what's active.

### Updating vendored plugins

```bash
./vendor.sh            # all
./vendor.sh mini.nvim  # one
git diff --stat && git commit -am "vendor: bump"
```

Pinned revisions are in `nvim/.config/nvim/VENDORED.md`.
