if status is-interactive

  #fish_add_path -m /usr/local/bin

  # --- Alias Stuff ---
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

  # --- Eza Stuff ---
  set -Ux EZA_STANDARD_OPTIONS --long --all --icons


  # ---- Zoxide (better cd) ----
  alias cd 'z'
  set --universal zoxide_hook

  
  # Initialize starship
  starship init fish | source

  # Setup thefuck
  thefuck --alias | source
end


