# ~/.bashrc — universal bash. Zero hard dependencies: every tool below is
# feature-detected, so this works on a fresh minimal host.

# System defaults (Fedora/RHEL ship /etc/bashrc; Debian sources its own).
[ -f /etc/bashrc ] && . /etc/bashrc

# ─── PATH ─────────────────────────────────────────────────
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
case ":$PATH:" in *":$HOME/bin:"*) ;; *) [ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH" ;; esac
export PATH

# ─── Editor: best available ───────────────────────────────
if command -v nvim >/dev/null 2>&1; then EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then EDITOR=vim
else EDITOR="vi"; fi
export EDITOR VISUAL="$EDITOR"

# Non-interactive shells stop here (scp, rsync, ssh host cmd).
[[ $- != *i* ]] && return

# ─── History ──────────────────────────────────────────────
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
shopt -s histappend checkwinsize cmdhist globstar 2>/dev/null

# ─── Aliases ──────────────────────────────────────────────
alias edit-bash='$EDITOR ~/.bashrc'
alias reload-bash='source ~/.bashrc'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# bat is "batcat" on Debian/Ubuntu. Never shadow cat itself — scripts and
# copy/paste pipelines expect plain output.
if command -v bat >/dev/null 2>&1; then alias bcat='bat'
elif command -v batcat >/dev/null 2>&1; then alias bcat='batcat'; alias bat='batcat'; fi
export BAT_THEME="${BAT_THEME:-ansi}"

# ls: lsd → eza → coreutils
if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd' ll='lsd -l' la='lsd -la' l='lsd -lah' lt='lsd --tree'
elif command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons' ll='eza -l --icons --git' la='eza -la --icons --git' \
          l='eza -lah --icons --git' lt='eza --tree --icons'
else
    alias ls='ls --color=auto' ll='ls -l' la='ls -lA' l='ls -lAh'
fi

# ─── Tools (only if installed) ────────────────────────────
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash --cmd cd)"
# fzf ≥0.48 ships its own integration; older versions silently skip.
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash 2>/dev/null)"

# tssh: complete hostnames from ~/.ssh/config/known_hosts if bash-completion is loaded.
type _known_hosts >/dev/null 2>&1 && complete -F _known_hosts tssh

# ─── Prompt ───────────────────────────────────────────────
# Pure bash PS1 with git branch. Starship takes over only if installed.
__git_ps1_lite() {
    local b
    b=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
    printf ' (%s)' "$b"
}
__set_ps1() {
    local rc=$? c_user c_host c_dir='\[\e[38;5;111m\]' c_git='\[\e[38;5;141m\]' r='\[\e[0m\]'
    local c_rc='\[\e[38;5;150m\]'
    [ $rc -ne 0 ] && c_rc='\[\e[38;5;204m\]'
    if [ "$EUID" -eq 0 ]; then c_user='\[\e[38;5;204m\]'; else c_user='\[\e[38;5;150m\]'; fi
    c_host='\[\e[38;5;180m\]'
    local ssh=''
    [ -n "$SSH_CONNECTION" ] && ssh='\[\e[38;5;215m\][ssh]'"$r "
    PS1="${ssh}${c_user}\u${r}@${c_host}\h${r} ${c_dir}\w${r}${c_git}\$(__git_ps1_lite)${r}\n${c_rc}\\\$${r} "
}
if command -v starship >/dev/null 2>&1 && [ -z "$DOTFILES_NO_STARSHIP" ]; then
    eval "$(starship init bash)"
else
    PROMPT_COMMAND="__set_ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

# ─── Machine-local overrides (never committed) ────────────
if [ -d "$HOME/.bashrc.d" ]; then
    # shellcheck disable=SC1090
    for rc in "$HOME"/.bashrc.d/*.sh; do [ -r "$rc" ] && . "$rc"; done
    unset rc
fi
# shellcheck disable=SC1091
[ -r "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
