#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "==> Respaldando archivos existentes en: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        local rel="${target#$HOME/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        cp -a "$target" "$BACKUP_DIR/$rel"
    fi
}

echo "==> Instalando archivos base de HOME (~/.bashrc, ~/.bash_profile, ~/.Xresources)..."
for f in .bashrc .bash_profile .Xresources; do
    backup_if_exists "$HOME/$f"
    cp "$REPO_DIR/home/$f" "$HOME/$f"
done

echo "==> Instalando scripts en ~/scripts y ~/.local/bin..."
backup_if_exists "$HOME/scripts"
mkdir -p "$HOME/scripts" "$HOME/.local/bin"
cp -r "$REPO_DIR/scripts/"* "$HOME/scripts/"
chmod +x "$HOME/scripts/"*.py "$HOME/scripts/"*.sh 2>/dev/null || true

for b in "$REPO_DIR/bin/"*; do
    name="$(basename "$b")"
    backup_if_exists "$HOME/.local/bin/$name"
    cp "$b" "$HOME/.local/bin/$name"
    chmod +x "$HOME/.local/bin/$name"
done

echo "==> Instalando configuraciones en ~/.config..."
mkdir -p "$HOME/.config"
for dir in "$REPO_DIR/config/"*; do
    name="$(basename "$dir")"
    backup_if_exists "$HOME/.config/$name"
    mkdir -p "$HOME/.config/$name"
    cp -r "$dir/"* "$HOME/.config/$name/"
done

echo "==> ¡Configuración de usuario restaurada con éxito!"
echo "    Respaldo anterior guardado en: $BACKUP_DIR"
echo ""
echo "Pasos opcionales de sistema (requieren sudo, revisar antes de ejecutar):"
echo "  - Boot silencioso y grupos (video, input): sudo bash $REPO_DIR/system/fix_system_boot.sh"
echo "  - Optimización de ZRAM, sysctl, journald y Xorg: sudo bash $REPO_DIR/system/optimizar.sh"
