if status is-interactive

  # --- Alias Stuff ---
  alias la 'ls -la'
  alias edit-fish 'nvim ~/.config/fish/config.fish'
  alias reload-fish 'source ~/.config/fish/config.fish'

  # --- Neovim Stuff ---
  set -x EDITOR nvim
  set -x PATH $HOME/.local/share/nvim/mason/bin $PATH
  alias vi 'nvim'
  alias nano 'nvim'
  alias vim 'nvim'

  # --- Bat Stuff ---
  alias cat 'bat'
  set -x BAT_THEME tokyonight_night

  # ---- Zoxide (better cd) ----
  alias cd 'z'
  eval (zoxide init fish)
  
  # Initialize starship
  eval (starship init fish)
end
