if status is-interactive

  # --- Aliases ---
  alias edit-fish='vi ~/.config/fish/config.fish'
  alias reload-fish='source ~/.config/fish/config.fish'

  # --- Bat Stuff ---
  alias cat='bat'

  
  # --- lsd (modern ls) ---
  alias ls='lsd --icon=always'          # minimal
  alias ll='lsd -l --icon=always'       # long
  alias la='lsd -la --icon=always'      # long + all
  alias l='lsd -lah --icon=always'      # long + all + human

  # --- Zoxide (better cd) ---
  if type -q zoxide
    zoxide init fish | source
    alias cd='z'
  end

  if type -q starship
    starship init fish | source
  end

  function fish_greeting
    echo ""
    echo "██╗  ██╗ ██████╗ ██████╗  ██████╗ ███████╗██╗███████╗██╗  ██╗"
    echo "██║  ██║██╔═══██╗██╔══██╗██╔═══██╗██╔════╝██║██╔════╝██║  ██║"
    echo "███████║██║   ██║██████╔╝██║   ██║█████╗  ██║███████╗███████║"
    echo "██╔══██║██║   ██║██╔══██╗██║   ██║██╔══╝  ██║╚════██║██╔══██║"
    echo "██║  ██║╚██████╔╝██████╔╝╚██████╔╝██║     ██║███████║██║  ██║"
    echo ""
  end

end
