#!/usr/bin/env bash
# setup.sh — install packages and stow dotfiles.
#
# Tiers (GNU Stow packages):
#   shell    bash, tmux, vim, git, ssh config, tssh/xpanes   — any host
#   desktop  shell + fish, zsh, starship, terminator, fastfetch
#   nvim     neovim config with vendored plugins (offline)  — opt-in on shell,
#            default on desktop
#
# Usage: ./setup.sh [--tier shell|desktop] [--nvim|--no-nvim] [--extras]
#                   [--stow-only] [--dry-run] [--yes] [--font]
#
#   --extras     community packages (starship, lazygit, zsh plugins)
#   --stow-only  link configs, install nothing (no sudo needed)
#   --dry-run    print what would happen
#   --yes        no prompts; defaults: tier=shell, nvim if installed
#   --font       install Meslo Nerd Font (desktop)
#
# Existing files that would conflict are moved to ~/.dotfiles-backup/<time>/,
# never overwritten. Safe to re-run.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)-$$"

# ─── Output ──────────────────────────────────────────────
if [ -t 1 ]; then
    BOLD=$'\e[1m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m' NC=$'\e[0m'
else
    BOLD="" RED="" GRN="" YLW="" BLU="" NC=""
fi
info() { echo "${BLU}::${NC} $*"; }
ok()   { echo "${GRN}ok${NC} $*"; }
warn() { echo "${YLW}!!${NC} $*" >&2; }
die()  { echo "${RED}xx${NC} $*" >&2; exit 1; }

# ─── Args ────────────────────────────────────────────────
TIER="" NVIM="" EXTRAS=false STOW_ONLY=false DRY_RUN=false ASSUME_YES=false WANT_FONT=false
while [ $# -gt 0 ]; do
    case "$1" in
        --tier)      TIER="${2:-}"; shift ;;
        --tier=*)    TIER="${1#*=}" ;;
        --nvim)      NVIM=yes ;;
        --no-nvim)   NVIM=no ;;
        --extras)    EXTRAS=true ;;
        --stow-only) STOW_ONLY=true ;;
        --dry-run)   DRY_RUN=true ;;
        --yes|-y)    ASSUME_YES=true ;;
        --font)      WANT_FONT=true ;;
        -h|--help)   sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)           die "Unknown option: $1 (see --help)" ;;
    esac
    shift
done
case "$TIER" in ""|shell|desktop) ;; *) die "--tier must be shell or desktop" ;; esac

run() {
    if $DRY_RUN; then echo "   [dry-run] $*"; else "$@"; fi
}
ask() { # ask "question" → 0 for yes. --yes answers no to optional prompts.
    $ASSUME_YES && return 1
    local r; read -rp "$1 [y/N] " r; [[ "$r" =~ ^[Yy] ]]
}
SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

# ─── Distro detection ────────────────────────────────────
detect_distro() {
    [ -r /etc/os-release ] || die "/etc/os-release not found"
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO="${PRETTY_NAME:-$DISTRO_ID}"

    # Immutable/ostree (Bazzite, Silverblue, Kinoite, Bluefin) must be checked
    # BEFORE dnf — they ship dnf, but it can't layer packages.
    if [ -f /run/ostree-booted ] || command -v rpm-ostree >/dev/null 2>&1; then
        PKG="rpm-ostree"
    elif command -v dnf >/dev/null 2>&1; then PKG="dnf"
    elif command -v pacman >/dev/null 2>&1; then PKG="pacman"
    elif command -v apt-get >/dev/null 2>&1; then PKG="apt"
    else PKG="none"
    fi
}
detect_distro
info "Detected ${BOLD}${DISTRO}${NC} (package manager: ${BOLD}${PKG}${NC})"

# ─── Tier / nvim selection ───────────────────────────────
if [ -z "$TIER" ]; then
    if $ASSUME_YES; then TIER=shell
    else
        echo
        echo "  ${BOLD}1${NC}) shell    bash, tmux, vim, git, ssh, tssh   (servers, work boxes)"
        echo "  ${BOLD}2${NC}) desktop  shell + fish, zsh, terminator, fastfetch"
        echo
        read -rp "Tier [1]: " t
        case "${t:-1}" in 2|desktop) TIER=desktop ;; *) TIER=shell ;; esac
    fi
fi
if [ -z "$NVIM" ]; then
    if [ "$TIER" = desktop ]; then NVIM=yes
    elif command -v nvim >/dev/null 2>&1; then NVIM=yes
    elif ! $ASSUME_YES && ! $STOW_ONLY && ask "Install neovim + config?"; then NVIM=yes
    else NVIM=no
    fi
fi
info "Tier: ${BOLD}${TIER}${NC}  nvim: ${BOLD}${NVIM}${NC}  extras: ${BOLD}${EXTRAS}${NC}"

# ─── Packages ────────────────────────────────────────────
# CORE: base repos on every distro. Everything is optional at runtime —
# configs feature-detect — so a failed install never breaks the shell.
declare -A CORE DESKTOP EXTRA
CORE[dnf]="stow git tmux vim-enhanced bat eza zoxide fzf ripgrep fd-find unzip"
CORE[pacman]="stow git tmux vim bat eza zoxide fzf ripgrep fd unzip"
CORE[apt]="stow git tmux vim bat eza zoxide fzf ripgrep fd-find unzip"
DESKTOP[dnf]="zsh fish terminator fastfetch wl-clipboard xclip"
DESKTOP[pacman]="zsh fish terminator fastfetch wl-clipboard xclip"
DESKTOP[apt]="zsh fish terminator fastfetch wl-clipboard xclip"
EXTRA[dnf]="zsh-syntax-highlighting zsh-autosuggestions"
EXTRA[pacman]="starship lazygit zsh-syntax-highlighting zsh-autosuggestions"
EXTRA[apt]="zsh-syntax-highlighting zsh-autosuggestions"
CORE[rpm-ostree]="${CORE[dnf]}"; DESKTOP[rpm-ostree]="${DESKTOP[dnf]}"; EXTRA[rpm-ostree]="${EXTRA[dnf]}"

NEEDS_REBOOT=false
pkg_install() {
    [ $# -eq 0 ] && return 0
    case "$PKG" in
        dnf)        run $SUDO dnf install -y "$@" ;;
        rpm-ostree) run $SUDO rpm-ostree install --idempotent --allow-inactive "$@"; NEEDS_REBOOT=true ;;
        pacman)     run $SUDO pacman -S --needed --noconfirm "$@" ;;
        apt)        run $SUDO apt-get install -y "$@" ;;
    esac
}

install_packages() {
    [ "$PKG" = none ] && { warn "No supported package manager — skipping installs"; return; }
    [ "$PKG" = apt ] && run $SUDO apt-get update -qq

    # shellcheck disable=SC2206
    local list=(${CORE[$PKG]})
    # shellcheck disable=SC2206
    [ "$TIER" = desktop ] && list+=(${DESKTOP[$PKG]})
    [ "$NVIM" = yes ] && list+=(neovim)
    # shellcheck disable=SC2206
    $EXTRAS && list+=(${EXTRA[$PKG]})

    info "Installing: ${list[*]}"
    # One bad name shouldn't sink the batch on apt/pacman: fall back per-package.
    if ! pkg_install "${list[@]}"; then
        warn "Batch install failed, retrying one at a time"
        for p in "${list[@]}"; do pkg_install "$p" || warn "  skipped: $p"; done
    fi

    if $EXTRAS; then
        case "$PKG" in
            dnf)
                run $SUDO dnf copr enable -y atim/starship && run $SUDO dnf copr enable -y atim/lazygit \
                    && pkg_install starship lazygit || warn "COPR starship/lazygit failed" ;;
            rpm-ostree)
                for c in starship lazygit; do
                    run $SUDO curl -fsSLo "/etc/yum.repos.d/_copr_atim-$c.repo" \
                        "https://copr.fedorainfracloud.org/coprs/atim/$c/repo/fedora-$(rpm -E %fedora)/atim-$c-fedora-$(rpm -E %fedora).repo" \
                        || warn "COPR repo for $c failed"
                done
                pkg_install starship lazygit || true ;;
            apt)
                warn "starship/lazygit aren't in Debian/Ubuntu base repos — install manually if wanted" ;;
        esac
    fi
}

# ─── Stow with backups ───────────────────────────────────
# Packages whose top-level dir is linked whole (folded). Everything else is
# stowed --no-folding so ~/.ssh, ~/.config/fish etc. stay real directories
# and nothing you create later lands inside the repo.
declare -A FOLD=( [nvim]=".config/nvim" )

backup() { # backup <path-relative-to-HOME>
    local rel="$1"
    info "  backing up ~/$rel → ${BACKUP_DIR/#$HOME/~}/$rel"
    run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    run mv "$HOME/$rel" "$BACKUP_DIR/$rel"
}

owned_by_repo() { # symlink resolving into this repo?
    [ -L "$1" ] && [[ "$(readlink -f "$1")" == "$DOTFILES_DIR"/* ]]
}

# ─── Symlinked parent directories ────────────────────────
# Stow can only place links inside REAL directories. If ~/.ssh (or ~/.config,
# ...) is itself a symlink, we must never move or inspect files through it.
#   → link into this repo (old folded stow): unfold it. The link is replaced
#     by a real dir; files git doesn't track (keys, local state) move out of
#     the repo into it; tracked files stay and get re-linked by stow.
#   → link anywhere else: stop before changing anything.
pkg_dirs() { # every parent dir (relative to $HOME) stow will need, shallowest first
    local pkg rel d
    for pkg in "$@"; do
        if [ -n "${FOLD[$pkg]:-}" ]; then
            d="$(dirname "${FOLD[$pkg]}")"
            while [ "$d" != . ]; do echo "$d"; d="$(dirname "$d")"; done
        else
            (cd "$DOTFILES_DIR/$pkg" && find . -mindepth 1 -type d) | sed 's|^\./||'
        fi
    done | awk -F/ '{print NF "\t" $0}' | sort -n -u | cut -f2-
}

REPO_LINKS=() EXT_LINKS=()
scan_parent_links() {
    REPO_LINKS=() EXT_LINKS=()
    local d covered l
    while IFS= read -r d; do
        [ -n "$d" ] || continue
        covered=false # a deeper path under an already-flagged link is moot
        for l in ${REPO_LINKS[@]+"${REPO_LINKS[@]}"} ${EXT_LINKS[@]+"${EXT_LINKS[@]}"}; do
            [[ "$d" == "$l"/* ]] && { covered=true; break; }
        done
        $covered && continue
        if [ -L "$HOME/$d" ]; then
            if owned_by_repo "$HOME/$d"; then REPO_LINKS+=("$d"); else EXT_LINKS+=("$d"); fi
        fi
    done < <(pkg_dirs "$@")
}

unfold_repo_link() { # unfold_repo_link <dir-relative-to-HOME>
    local rel="$1" src p sub moved=0
    src="$(readlink -f "$HOME/$rel")"
    info "  unfolding ~/$rel (was a link into the repo: ${src#"$DOTFILES_DIR"/})"
    run rm "$HOME/$rel"              # removes the link only, never its target
    run mkdir -p "$HOME/$rel"
    # Untracked + ignored files under src = user data that leaked into the repo.
    while IFS= read -r p; do
        [ -n "$p" ] || continue
        sub="${p#"${src#"$DOTFILES_DIR"/}"/}"
        run mkdir -p "$HOME/$rel/$(dirname "$sub")"
        run mv "$DOTFILES_DIR/$p" "$HOME/$rel/$sub"
        moved=$((moved + 1))
    done < <(git -C "$DOTFILES_DIR" ls-files --others -- "${src#"$DOTFILES_DIR"/}")
    [ $moved -gt 0 ] && info "  moved $moved untracked file(s) from the repo back into ~/$rel"
    return 0
}

resolve_parent_links() {
    scan_parent_links "$@"
    if [ ${#EXT_LINKS[@]} -gt 0 ]; then
        warn "These directories are symlinks to somewhere outside this repo:"
        local l
        for l in "${EXT_LINKS[@]}"; do warn "  ~/$l -> $(readlink "$HOME/$l")"; done
        warn "Stow can only link into real directories, and moving the link would"
        warn "hide whatever lives behind it. Nothing has been changed."
        die "Make each a real directory (e.g. rm ~/X && cp -a <target> ~/X), then re-run."
    fi
    if [ ${#REPO_LINKS[@]} -gt 0 ]; then
        git -C "$DOTFILES_DIR" rev-parse --git-dir >/dev/null 2>&1 \
            || die "$HOME/${REPO_LINKS[0]} links into the repo, but this copy has no .git to tell your files from tracked ones. Unfold it by hand."
        local l; for l in "${REPO_LINKS[@]}"; do unfold_repo_link "$l"; done
    fi
}

preflight() { # move aside any FILE stow would refuse to replace
    local pkg="$1" rel t
    if [ -n "${FOLD[$pkg]:-}" ]; then
        rel="${FOLD[$pkg]}"; t="$HOME/$rel"
        if { [ -e "$t" ] || [ -L "$t" ]; } && ! owned_by_repo "$t"; then backup "$rel"; fi
        return
    fi
    local l
    while IFS= read -r rel; do
        rel="${rel#./}"; t="$HOME/$rel"
        # dry-run: a dir we'd unfold is still a link, so its contents aren't conflicts
        if $DRY_RUN; then
            for l in ${REPO_LINKS[@]+"${REPO_LINKS[@]}"}; do [[ "$rel" == "$l"/* ]] && continue 2; done
        fi
        if [ -L "$t" ]; then owned_by_repo "$t" || backup "$rel"
        elif [ -e "$t" ]; then backup "$rel"
        fi
    done < <(cd "$DOTFILES_DIR/$pkg" && find . \( -type f -o -type l \))
}

stow_pkg() {
    local pkg="$1" fold_flag="--no-folding"
    [ -n "${FOLD[$pkg]:-}" ] && { fold_flag=""; run mkdir -p "$HOME/$(dirname "${FOLD[$pkg]}")"; }
    preflight "$pkg"
    # shellcheck disable=SC2086
    if run stow --dir="$DOTFILES_DIR" --target="$HOME" --restow $fold_flag "$pkg"; then
        ok "linked ${BOLD}$pkg${NC}"
    else
        die "stow failed for $pkg"
    fi
}

# ─── Main ────────────────────────────────────────────────
PKGS=(shell)
[ "$TIER" = desktop ] && PKGS+=(desktop)
[ "$NVIM" = yes ] && PKGS+=(nvim)

# Read-only check first: an unsafe symlinked dir aborts before any install.
scan_parent_links "${PKGS[@]}"
[ ${#EXT_LINKS[@]} -gt 0 ] && resolve_parent_links "${PKGS[@]}"

$STOW_ONLY || install_packages
command -v stow >/dev/null 2>&1 || $DRY_RUN || die "GNU stow not installed (try without --stow-only)"

info "Stowing: ${PKGS[*]}"
resolve_parent_links "${PKGS[@]}"
for p in "${PKGS[@]}"; do stow_pkg "$p"; done

# Only now: ~/.ssh is guaranteed to be a real directory, not a link.
run mkdir -p "$HOME/.ssh/config.d" "$HOME/.config/tssh/groups"
run chmod 700 "$HOME/.ssh"

# Version check without starting nvim (starting it would load whatever
# config/plugins are already on this box — not OK during a dry run or ever).
if [ "$NVIM" = yes ] && command -v nvim >/dev/null 2>&1; then
    nv="$(nvim --version 2>/dev/null | sed -n '1s/^NVIM v\([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')"
    read -r nv_major nv_minor <<< "$nv"
    if [ -n "${nv_major:-}" ] && [ "$nv_major" -eq 0 ] && [ "$nv_minor" -lt 10 ]; then
        warn "nvim 0.$nv_minor is < 0.10: plugins/LSP disabled. Grab a newer build (see docs/packages.md)."
    fi
fi

# ─── Git identity (kept out of the repo) ─────────────────
if [ ! -f "$HOME/.gitconfig.local" ] && ! $ASSUME_YES && ! $DRY_RUN; then
    if ask "Create ~/.gitconfig.local with your git name/email?"; then
        read -rp "  name: " gn; read -rp "  email: " ge
        printf '[user]\n    name = %s\n    email = %s\n' "$gn" "$ge" > "$HOME/.gitconfig.local"
        ok "wrote ~/.gitconfig.local"
    fi
fi

# ─── Font (desktop) ──────────────────────────────────────
if [ "$TIER" = desktop ] && ! $STOW_ONLY && { $WANT_FONT || ask "Install Meslo Nerd Font?"; }; then
    fdir="$HOME/.local/share/fonts/MesloNerd"
    ftmp="$(mktemp -d)"                       # private, not a guessable /tmp name
    trap 'rm -rf "$ftmp"' EXIT
    run mkdir -p "$fdir"
    if run curl -fsSLo "$ftmp/Meslo.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"; then
        { run unzip -oq "$ftmp/Meslo.zip" -d "$fdir" && run fc-cache -f "$fdir" && ok "Meslo Nerd Font installed"; } \
            || warn "Font extract failed"
    else
        warn "Font download failed (offline?) — use NVIM_ASCII=1 for ASCII icons"
    fi
fi

# ─── Done ────────────────────────────────────────────────
echo
ok "Done — tier ${BOLD}${TIER}${NC}, nvim ${BOLD}${NVIM}${NC}"
[ -d "$BACKUP_DIR" ] && info "Replaced files saved in ${BACKUP_DIR/#$HOME/~}"
$NEEDS_REBOOT && warn "Reboot to activate rpm-ostree layered packages."
info "Open a new shell or: exec \$SHELL"
