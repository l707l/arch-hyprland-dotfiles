#!/usr/bin/env bash
set -e

echo "[1/7] Instalando wireless-regdb para solucionar error de firmware Wi-Fi..."
pacman -S --needed --noconfirm wireless-regdb

echo "[2/7] Eliminando paquetes redundantes (xterm, w3m) y huérfanos..."
pacman -Rns --noconfirm xterm w3m 2>/dev/null || true
orphans=$(pacman -Qdtq || true)
if [ -n "$orphans" ]; then
    pacman -Rns --noconfirm $orphans
fi

echo "[3/7] Limpiando 1.1 GB de caché de pacman..."
pacman -Scc --noconfirm

echo "[4/7] Configurando Xorg modesetting para eliminar errores (EE) de drivers intel/fbdev/vesa..."
cat << "EOF" > /etc/X11/xorg.conf.d/20-modesetting.conf
Section "Device"
    Identifier "Intel Graphics"
    Driver "modesetting"
    Option "AccelMethod" "glamor"
    Option "TearFree" "true"
EndSection
EOF

echo "[5/7] Optimizando consumo de RAM (ZRAM) y CPU (desactivando NMI watchdog)..."
cat << "EOF" > /etc/sysctl.d/99-minimal-performance.conf
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
vm.vfs_cache_pressure = 50
kernel.nmi_watchdog = 0
EOF
sysctl --system >/dev/null

echo "[6/7] Desactivando servicios innecesarios y errores de Bluetooth (hci0 -16)..."
systemctl disable --now bluetooth.service 2>/dev/null || true
systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true
rm -f /etc/systemd/network/20-wwan.network

echo "[7/7] Limitando logs de systemd a 30MB y limpiando journal..."
mkdir -p /etc/systemd/journald.conf.d
cat << "EOF" > /etc/systemd/journald.conf.d/00-size.conf
[Journal]
SystemMaxUse=30M
EOF
systemctl restart systemd-journald
journalctl --vacuum-size=10M

rm -f /home/cian/optimizar.sh
echo "=== ¡Todo listo, limpio y optimizado al mínimo! ==="
