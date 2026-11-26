# Arch Linux + Hyprland (Lua) Dotfiles & Scripts

Respaldo completo y documentado de las configuraciones personalizadas sobre **Arch Linux** con **Hyprland** (configuración en Lua `hyprland.lua`), **Ironbar**, **Infinite Desktop v2**, **Serpantinum Launcher**, ajustes **HiDPI**, optimizaciones de **Audio (PipeWire / WirePlumber / EasyEffects)**, gestos multitáctiles y scripts de sistema.

---

## Estructura del Repositorio

```text
.
├── install.sh                                  # Script de restauración segura (hace backup previo)
├── home/
│   ├── .bashrc                                 # PATH con ~/.local/bin deduplicado
│   ├── .bash_profile                           # Autoarranque de Hyprland en tty1
│   └── .Xresources                             # Configuración Xft.dpi (86) y subpixel hinting
├── bin/
│   ├── captura-recorte                         # Captura de área con slurp + grim + wl-copy
│   └── serpantinum-launcher                    # Wrapper/daemon para Serpantinum en Quickshell
├── scripts/                                    # Scripts de escritorio infinito, HiDPI, ventanas y fondos
│   ├── infinite_desktop_core.py                # Motor principal de escritorio infinito
│   ├── infinite-desktop.sh                     # Utilidad de escritorio infinito
│   ├── hypr_ipc.py                             # Helper IPC para Hyprland
│   ├── navigate_windows.py                     # Navegación entre ventanas
│   ├── move_window.py / move_window_tiled.py   # Movimiento de ventanas flotantes y tiled
│   ├── resize_window.py                        # Redimensionado direccional de ventanas
│   ├── floating_tile_toggle.py                 # Alternar tiling/floating (Infinite Desktop)
│   ├── smart_float_toggle.py                   # Alternar flotante inteligente
│   ├── window_scale.py                         # Escalar/reducir ventana individual sin límites
│   ├── hidpi_scale.py                          # Escalado HiDPI global del monitor en caliente
│   ├── wallpaper_switcher.py                   # Selector de fondos de pantalla
│   ├── capture_wallpaper.py                    # Capturador de fondos MP4/GIF (Wallpaper Engine)
│   └── discover_hyprland_api.sh                # Descubrimiento de API de Hyprland
├── config/
│   ├── hypr/hyprland.lua                       # Configuración principal de Hyprland en Lua
│   ├── ironbar/{config.corn, style.css}        # Barra superior estilo Liquid Glass transparente
│   ├── environment.d/hidpi.conf                # Variables Wayland nativo & HiDPI (GDK, Qt, Electron, SDL)
│   ├── kitty/kitty.conf                        # Terminal Kitty con transparencia (0.85) y paleta oscura
│   ├── wofi/style.css                          # Estilos de Wofi
│   ├── niri/config.kdl                         # Configuración alternativa para Niri
│   ├── fusuma/config.yml                       # Gestos multitáctiles (3 y 4 dedos, pinch) para Niri/Hyprland
│   ├── touchegg/touchegg.conf                  # Configuración de Touchégg
│   ├── serpantinum/settings.json               # Configuración del lanzador circular Serpantinum
│   ├── pipewire/
│   │   ├── pipewire.conf.d/10-clock.conf       # Reloj a 48kHz, tasas 44.1/48/96kHz, quantum 64–2048
│   │   └── pipewire-pulse.conf.d/firefox-fix.conf # Latencia/quantum fijo para Firefox
│   ├── wireplumber/wireplumber.conf.d/
│   │   ├── 50-alsa-tuning.conf                 # Desactiva suspensión de salida ALSA (timeout=0)
│   │   └── 51-alsa-headroom.conf               # period-size=1024 y headroom=8192 anti-crujidos
│   └── easyeffects/db/easyeffectsrc            # Configuración de EasyEffects
└── system/
    ├── fix_system_boot.sh                      # Paquetes base, grupos video/input y boot silencioso (UKI)
    ├── optimizar.sh                            # ZRAM/sysctl, Xorg modesetting, journald 30MB, limpieza
    └── install-hyprland-infinite-desktop.sh    # Instalador de Hyprland Infinite Desktop v2
```

---

## Qué se configuró y cómo funciona

### 1. Hyprland (`config/hypr/hyprland.lua`)
- **Monitor principal (`eDP-1`)**: `1920x1080@60`, escala `1.25`.
- **Autostart**: carga `~/.Xresources`, inicia `ironbar`, arranca `infinite_desktop_core.py 1.6` y `serpantinum-launcher --daemon`.
- **Estética y reglas**:
  - `gaps_in = 1`, `gaps_out = 0`, `border_size = 0`.
  - Regla `ironbar-glass`: blur activo con `ignore_alpha = 0.1` para efecto *Liquid Glass*.
  - Regla `kitty-opacity`: texto 100% opaco (`1.0 0.92`) manteniendo el fondo transparente en `kitty.conf`.
  - Regla `suppress-browser-fullscreen`: evita que videos en navegadores (`firefox`, `google-chrome`, `chromium`, `brave-browser`, `zen`) fuercen pantalla completa global.

### 2. Barra Superior (`config/ironbar/`)
- Barra superior de `20px` totalmente transparente con tipografía `JetBrainsMono Nerd Font` / `AdwaitaMono Nerd Font`.
- Módulos izquierdos: `workspaces` (por monitor) y `focused` (icono de ventana activa).
- Módulos derechos: `tray`, botones rápidos de Wi-Fi (`kitty -e iwctl`) y Bluetooth (`blueman-manager`), batería, lectura de ventilador (`/sys/class/hwmon/hwmon3/fan1_input`) y reloj (`%H:%M`).

### 3. HiDPI y Wayland Nativo (`config/environment.d/hidpi.conf` y `scripts/hidpi_scale.py`)
- Fuerza Wayland nativo en GTK (`GDK_BACKEND=wayland,x11`), Qt (`QT_QPA_PLATFORM=wayland;xcb`, `QT_ENABLE_HIGHDPI_SCALING=1`), Firefox (`MOZ_ENABLE_WAYLAND=1`), Electron (`ELECTRON_OZONE_PLATFORM_HINT=auto`), SDL y Clutter.
- Permite ajustar la escala del monitor al vuelo con `hidpi_scale.py`.

### 4. Audio sin cortes (`config/pipewire/` y `config/wireplumber/`)
- **PipeWire**: `default.clock.rate = 48000`, `quantum = 1024` (rango `64`–`2048`), y regla dedicada en `pipewire-pulse` para estabilizar audio en `firefox`.
- **WirePlumber**: `session.suspend-timeout-seconds = 0` para evitar chasquidos al reanudar audio ALSA, más `period-size = 1024` y `headroom = 8192`.

### 5. Atajos principales de teclado (`SUPER`)

| Atajo | Acción |
| :--- | :--- |
| `SUPER + Q` | Abrir terminal (`kitty`) |
| `SUPER + E` | Abrir gestor de archivos (`thunar`) |
| `SUPER + R` / `SUPER + SPACE` | Abrir lanzador (`serpantinum-launcher`) |
| `SUPER + C` | Cerrar ventana activa |
| `SUPER + F` | Alternar pantalla completa |
| `SUPER + V` | Alternar flotante inteligente (`smart_float_toggle.py`) |
| `SUPER + D` | Alternar tiling/floating (`floating_tile_toggle.py`) |
| `SUPER + B` | Mostrar/ocultar barra `ironbar` |
| `Print` / `SUPER + SHIFT + S` | Captura de área (`captura-recorte`) |
| `SUPER + W` / `SUPER + SHIFT + W` | Cambiar fondo / capturar fondo MP4-GIF |
| `SUPER + +` / `SUPER + -` / `BackSpace` | Crecer / encoger / resetear tamaño de ventana |
| `SUPER + CTRL + +` / `-` / `SUPER + ALT + 0` | Subir / bajar / resetear escala HiDPI global |
| `SUPER + Z` / `X` | Cambiar al workspace anterior / siguiente |
| `SUPER + Flechas` | Navegar ventanas (Infinite Desktop) |
| `SUPER + SHIFT + Flechas` | Mover ventana |
| `SUPER + CTRL + Flechas` | Redimensionar ventana |
| `SUPER + ALT + Flechas` | Mover ventana en modo tiled |

---

## Cómo restaurar en una instalación nueva de Arch Linux

1. Clona este repositorio y entra en la carpeta:
   ```bash
   git clone <URL_DE_TU_REPO> ~/arch-hyprland-dotfiles
   cd ~/arch-hyprland-dotfiles
   ```
2. Ejecuta el instalador de configuraciones de usuario (creará un respaldo automático de tus archivos previos en `~/.dotfiles_backup_*`):
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
3. *(Opcional, requiere `sudo`)* Revisa y ejecuta los scripts de sistema si estás configurando un equipo desde cero:
   ```bash
   sudo bash system/fix_system_boot.sh
   sudo bash system/optimizar.sh
   ```
   > **Nota**: `system/fix_system_boot.sh` asume el usuario `cian` y kernel UKI (`/etc/kernel/cmdline` + `mkinitcpio -P`). `system/optimizar.sh` desactiva `bluetooth.service` y borra el propio archivo tras ejecutarse; revísalos antes de correrlos en otro equipo.
