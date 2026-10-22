# .zshrc

# Source global definitions (zsh)
[[ -f /etc/zshrc ]] && source /etc/zshrc

# User-specific PATH (prepend if missing)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  PATH="$HOME/.local/bin:$PATH"
fi
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  PATH="$HOME/bin:$PATH"
fi
export PATH

# Optional: de-duplicate PATH entries
typeset -U path

# Load per-file snippets (zsh)
if [[ -d ~/.zshrc.d ]]; then
  for rc in ~/.zshrc.d/*(.N); do
    [[ -f "$rc" ]] && source "$rc"
  done
fi
unset rc

# Editor: best available
if (( $+commands[nvim] )); then export EDITOR=nvim
elif (( $+commands[vim] )); then export EDITOR=vim
else export EDITOR=vi; fi
export VISUAL=$EDITOR

# Only run in interactive shells
[[ -o interactive ]] || return

# --- Aliases ---
alias edit-zsh='$EDITOR ~/.zshrc'
alias reload-zsh='source ~/.zshrc'

# keep bash helpers if you still use them
alias edit-bash='$EDITOR ~/.bashrc'
alias reload-bash='source ~/.bashrc'

# --- Bat (batcat on Debian/Ubuntu). Don't shadow cat. ---
if (( $+commands[bat] )); then alias bcat='bat'
elif (( $+commands[batcat] )); then alias bcat='batcat' bat='batcat'; fi

# --- ls: lsd → eza → plain ---
if (( $+commands[lsd] )); then
  alias ls='lsd --icon=always' ll='lsd -l --icon=always' la='lsd -la --icon=always' l='lsd -lah --icon=always'
elif (( $+commands[eza] )); then
  alias ls='eza --icons' ll='eza -l --icons --git' la='eza -la --icons --git' l='eza -lah --icons --git'
fi

# --- Zoxide (better cd) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# --- Starship ---
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- Completion (zsh built-ins) ---
autoload -Uz compinit && compinit

####################################################################
# Fish-y goodness: fast-syntax-highlighting + zsh-autosuggestions  #
####################################################################

# Helper: source the first existing file from a list
_zsh_source_first() {
  local f
  for f in "$@"; do
    [[ -r "$f" ]] && source "$f" && return 0
  done
  return 1
}

# --- fast-syntax-highlighting (snappy token colors) ---
# Try common install locations (Arch, Debian/Ubuntu, brew, manual clone)
_zsh_source_first \
  /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  /usr/share/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  /usr/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  /opt/homebrew/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  /usr/local/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  "$HOME/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

# Optional: tweak a couple styles (comment these if you don’t care)
typeset -gA FAST_HIGHLIGHT_STYLES
FAST_HIGHLIGHT_STYLES[path]="fg=cyan"
FAST_HIGHLIGHT_STYLES[command]="fg=green,bold"
FAST_HIGHLIGHT_STYLES[unknown-token]="fg=red,bold"

# --- zsh-autosuggestions (ghost text from history/completion) ---
# Strategy: suggest from history first, then completion if available
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# Subtle gray suggestion text (works in most terminals)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

_zsh_source_first \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Key behavior:
# - Accept suggestion with → (default)
# - Accept to word with Alt-f
# - Toggle suggestions on/off (Ctrl-Alt-s)
bindkey '^[f' forward-word
zle -N autosuggest-toggle
bindkey '^[^S' autosuggest-toggle

# Machine-local overrides (never committed)
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
