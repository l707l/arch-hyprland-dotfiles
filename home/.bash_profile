#
# ~/.bash_profile
#

case ":$PATH:" in
  *":/home/cian/.local/bin:"*) ;;
  *) export PATH="/home/cian/.local/bin:$PATH" ;;
esac

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Start Hyprland automatically upon login on TTY1
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi
