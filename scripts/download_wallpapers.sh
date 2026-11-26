#!/usr/bin/env bash
set -euo pipefail

DEST="${HOME}/Wallpapers"
REPO="l707l/arch-hyprland-dotfiles"
TAG="wallpapers-v1"

mkdir -p "$DEST"

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    echo "==> Descargando videos de wallpaper con gh en $DEST..."
    gh release download "$TAG" -R "$REPO" -D "$DEST" --clobber
else
    echo "==> Descargando videos de wallpaper con curl en $DEST..."
    URLS=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/tags/$TAG" \
        | grep -oE '"browser_download_url":\s*"[^"]+"' \
        | cut -d'"' -f4)
    for url in $URLS; do
        filename=$(basename "$url")
        echo "  -> $filename"
        curl -fL --progress-bar -o "$DEST/$filename" "$url"
    done
fi

echo "==> ¡Listo! Videos guardados en $DEST"
