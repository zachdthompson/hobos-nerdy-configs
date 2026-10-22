# Keybinds

In nvim you never need this file: press `<Space>` and pause for a popup, or
`<Space>fk` to fuzzy-search every mapping. In tmux, `prefix ?` lists all keys.

## tmux (prefix = `C-b`)

| keys | action |
|---|---|
| `\` / `-` | split side-by-side / stacked (keeps cwd) |
| `h j k l` | select pane |
| `H J K L` | resize pane (repeat without prefix) |
| `m` or `z` | zoom pane |
| `e` | **toggle broadcast** (synchronize-panes) |
| `<` / `>` | move window left / right (repeatable) |
| `M` | swap window with index … |
| `W` | move window to another session … |
| `@` | pull a pane in from window … |
| `!` | break pane out to its own window |
| `{` / `}` | swap pane with previous / next |
| `g` | lazygit popup |
| `r` | reload config |
| `F12` *(no prefix)* | suspend this tmux for nested sessions |
| `[` then `v` / `y` | copy mode: select / yank (OSC52 to local clipboard) |

## nvim (leader = `Space`)

| keys | action |
|---|---|
| `jk` | leave insert |
| **Explorer** | |
| `<leader>ee` / `ef` / `ec` / `er` | tree toggle / at file / collapse / refresh |
| `g?` *(in tree)* | tree help |
| **Find** | |
| `<leader>ff` | files (incl. dotfiles) |
| `<leader>fr` / `fb` / `fh` | recent / buffers / help |
| `<leader>fs` / `fc` | live grep / grep word under cursor |
| `<leader>ft` | TODO/FIXME/HACK/NOTE |
| `<leader>fk` | **search keymaps** |
| `<leader>fd` / `fg` | diagnostics / git hunks |
| `<leader>f/` / `f:` / `fR` | lines in buffer / command history / resume |
| in picker | `C-j`/`C-k` move, `C-s`/`C-v`/`C-t` open split/vsplit/tab, `C-x` mark, `M-CR` marked → quickfix |
| **Splits / tabs / buffers** | |
| `<leader>sv` / `sh` / `se` / `sx` / `sm` | vsplit / hsplit / equalize / close / maximize |
| `C-h j k l` | move between splits |
| `C-arrows` | resize split |
| `<leader>to` / `tx` / `tn` / `tp` / `tf` | tab new / close / next / prev / buffer→tab |
| `S-h` / `S-l` / `<leader>bd` | prev / next buffer / delete buffer (keep split) |
| **LSP** (when a server is attached) | |
| `gd` / `gR` / `gi` / `gt` / `gD` | definition / references / implementation / type / declaration |
| `K` | hover docs |
| `<leader>ca` / `rn` / `mp` | code action / rename / format |
| `<leader>cs` / `cS` / `ch` | doc symbols / workspace symbols / inlay hints |
| `<leader>d` / `<leader>D` | line diagnostics / buffer diagnostics |
| `[d` / `]d` | prev / next diagnostic |
| `<leader>rs` | restart LSP |
| **Git** | |
| `]h` / `[h` | next / prev hunk |
| `gh{motion}` / `gH{motion}` | stage / reset hunk (`ghgh` = this hunk) |
| `<leader>go` / `gb` / `lg` | diff overlay / blame / lazygit |
| **Editing** | |
| `ys{motion}{char}` / `ds{char}` / `cs{old}{new}` | surround add / delete / change |
| `S` *(visual)* / `yss` | surround selection / line |
| `gcc` / `gc{motion}` | comment |
| `M-h j k l` | move line or selection |
| `af` `if` `aa` `ia` `a(` … | extra text objects (mini.ai) |
| **Sessions / terminal** | |
| `<leader>ws` / `wr` / `wl` | save / restore session for cwd / list |
| `<leader>Tt` / `Ts` | floating terminal / terminal split |
| `Esc Esc` | leave terminal mode |
