#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Por favor ejecuta este script con sudo: sudo bash $0"
  exit 1
fi

echo "==> 1. Instalando wireless-regdb y herramientas básicas para Hyprland..."
pacman -S --needed --noconfirm wireless-regdb brightnessctl playerctl wofi thunar

echo "==> 2. Añadiendo usuario cian a los grupos video e input..."
usermod -aG video,input cian

echo "==> 3. Configurando inicio limpio (sin errores ni logs en pantalla)..."
CMDLINE_FILE="/etc/kernel/cmdline"
if [ -f "$CMDLINE_FILE" ]; then
    CURRENT_CMDLINE=$(cat "$CMDLINE_FILE")
    if ! grep -q "quiet" "$CMDLINE_FILE"; then
        echo "$CURRENT_CMDLINE quiet loglevel=3 systemd.show_status=auto rd.udev.log_level=3" > "$CMDLINE_FILE"
        echo "Parámetros añadidos a $CMDLINE_FILE:"
        cat "$CMDLINE_FILE"
    else
        echo "Los parámetros quiet/loglevel ya estaban configurados en $CMDLINE_FILE."
    fi
fi

echo "==> 4. Regenerando imagen del Kernel / UKI (arch-linux.efi)..."
mkinitcpio -P

echo "==> ¡Listo! Todo configurado con éxito."
