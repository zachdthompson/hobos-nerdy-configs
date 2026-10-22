# ~/.config/fish/config.fish — hobo's custom fish.
# Machine-local overrides: ~/.config/fish/conf.d/local.fish (fish auto-sources
# conf.d/ before this file; nothing there is committed).

fish_add_path -g ~/.local/bin

if type -q nvim
    set -gx EDITOR nvim
else if type -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end
set -gx VISUAL $EDITOR

if status is-interactive

    # --- Aliases ---
    alias edit-fish='$EDITOR ~/.config/fish/config.fish'
    alias reload-fish='source ~/.config/fish/config.fish'

    # --- bat (batcat on Debian/Ubuntu). Don't shadow cat. ---
    if type -q bat
        alias bcat='bat'
    else if type -q batcat
        alias bcat='batcat'
        alias bat='batcat'
    end

    # --- ls: lsd → eza → plain ---
    if type -q lsd
        alias ls='lsd --icon=always'
        alias ll='lsd -l --icon=always'
        alias la='lsd -la --icon=always'
        alias l='lsd -lah --icon=always'
        alias lt='lsd --tree --icon=always'
    else if type -q eza
        alias ls='eza --icons'
        alias ll='eza -l --icons --git'
        alias la='eza -la --icons --git'
        alias l='eza -lah --icons --git'
        alias lt='eza --tree --icons'
    end

    # --- Zoxide (better cd) ---
    if type -q zoxide
        zoxide init fish --cmd cd | source
    end

    # --- fzf (≥0.48 ships fish integration) ---
    if type -q fzf
        fzf --fish 2>/dev/null | source
    end

    # --- Starship ---
    if type -q starship; and not set -q DOTFILES_NO_STARSHIP
        starship init fish | source
    end

    # --- tssh: complete hosts and @groups ---
    complete -c tssh -f -a '(__fish_print_hostnames)'
    complete -c tssh -f -a '(path basename ~/.config/tssh/groups/* 2>/dev/null | string replace -r "^" "@")'
    complete -c tssh -s J -d 'ProxyJump host' -x -a '(__fish_print_hostnames)'
    complete -c tssh -s l -d 'Remote user' -x
    complete -c tssh -s d -d 'Start with broadcast off'

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
