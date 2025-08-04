# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Only run in interactive shells
[[ $- != *i* ]] && return

# --- Aliases ---
alias edit-bash='nvim ~/.bashrc'
alias reload-bash='source ~/.bashrc'

# Keep fish helpers if you still bounce between shells
alias edit-fish='nvim ~/.config/fish/config.fish'
alias reload-fish='source ~/.config/fish/config.fish'

# --- Bat ---
export BAT_THEME="tokyonight_night"
alias cat='bat'

# --- lsd (modern ls) ---
# Nerd Font gives you icons; lsd defaults to --icon=auto
alias ls='lsd'          # minimal
alias ll='lsd -l'       # long
alias la='lsd -la'      # long + all
alias l='lsd -lah'      # long + all + human

# --- Zoxide (better cd) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)"
fi

# --- Starship ---
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# --- thefuck ---
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi
