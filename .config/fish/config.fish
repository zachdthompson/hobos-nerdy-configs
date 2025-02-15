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
  alias ls='eza --icons=always'

  # --- Bat Stuff ---
  alias cat 'bat'
  set -x BAT_THEME tokyonight_night

  # --- Eza Stuff ---
  set -Ux EZA_STANDARD_OPTIONS --long --all --icons


  # ---- Zoxide (better cd) ----
  zoxide init fish --cmd cd | source
  
  # Initialize starship
  starship init fish | source

  # Setup thefuck
  thefuck --alias | source

  # Functions
  function launch-tsm
    /home/hobo/Scripts/launcher.sh
  end
end
