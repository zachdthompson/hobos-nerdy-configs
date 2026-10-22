#!/usr/bin/env bash
# vendor.sh — refresh third-party code committed into this repo.
#
# Run on a personal machine with git + network. Commit the result. Work and
# air-gapped hosts never run this; they just get the files from the repo.
# Nothing in the repo fetches anything at runtime.
#
#   ./vendor.sh            update everything to upstream HEAD
#   ./vendor.sh mini.nvim  update one item

set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

PACK="nvim/.config/nvim/pack/vendor/opt"
MANIFEST="nvim/.config/nvim/VENDORED.md"

# name | repo | paths to keep (everything else — tests, media, CI — dropped)
ITEMS=(
  "mini.nvim|nvim-mini/mini.nvim|lua doc LICENSE"
  "nvim-tree.lua|nvim-tree/nvim-tree.lua|lua doc plugin LICENSE"
  "tokyonight.nvim|folke/tokyonight.nvim|lua colors doc LICENSE"
  "tmux-xpanes|greymd/tmux-xpanes|bin/xpanes LICENSE"
)

only="${1:-}"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$PACK"

for item in "${ITEMS[@]}"; do
    IFS='|' read -r name repo keep <<<"$item"
    [ -n "$only" ] && [ "$only" != "$name" ] && continue
    echo "==> $name ($repo)"
    git clone -q --depth 1 "https://github.com/$repo.git" "$tmp/$name"
    rev="$(git -C "$tmp/$name" rev-parse --short HEAD)"

    if [ "$name" = "tmux-xpanes" ]; then
        install -m 755 "$tmp/$name/bin/xpanes" shell/.local/bin/xpanes
        mkdir -p third_party && cp "$tmp/$name/LICENSE" third_party/tmux-xpanes.LICENSE
    else
        rm -rf "${PACK:?}/$name"; mkdir -p "$PACK/$name"
        for p in $keep; do cp -r "$tmp/$name/$p" "$PACK/$name/"; done
        # Upstream .gitignore files (e.g. nvim-tree ignores doc/tags) would keep
        # vendored files out of this repo — drop them.
        find "$PACK/$name" -name .gitignore -delete
        # Opt packages need prebuilt help tags so :help works offline.
        if [ -d "$PACK/$name/doc" ] && command -v nvim >/dev/null; then
            nvim --headless --clean -c "helptags $PACK/$name/doc" -c q 2>/dev/null || true
        fi
    fi

    # Record pinned revision
    touch "$MANIFEST"
    grep -v "^| $name |" "$MANIFEST" > "$tmp/m" || true
    printf '| %s | %s | %s | %s |\n' "$name" "$repo" "$rev" "$(date +%F)" >> "$tmp/m"
    { echo "# Vendored third-party code"; echo; echo "Refresh with ./vendor.sh. Each keeps its own LICENSE."; echo
      echo "| name | upstream | rev | vendored |"; echo "|---|---|---|---|"
      grep '^| ' "$tmp/m" | grep -v '^| name |' | sort; } > "$MANIFEST"
done
echo "Done. Review with: git status && git diff --stat"
