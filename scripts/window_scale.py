#!/usr/bin/env python3
"""Zoom typography/content inside the active window without shrinking the window."""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from hypr_ipc import dispatch, hyprctl_json

TERMINAL_CLASSES = {
    "kitty",
    "alacritty",
    "foot",
    "wezterm",
    "org.wezfurlong.wezterm",
    "konsole",
    "gnome-terminal",
    "gnome-terminal-server",
    "xfce4-terminal",
    "terminator",
    "ghostty",
    "com.mitchellh.ghostty",
}


def main() -> int:
    action = sys.argv[1] if len(sys.argv) > 1 else "reset"
    if action not in ("shrink", "grow", "reset"):
        print("Usage: window_scale.py [shrink|grow|reset]", file=sys.stderr)
        return 1

    win = hyprctl_json(["activewindow"])
    if not win or not win.get("address"):
        return 0

    cls = (win.get("class") or "").lower()
    is_term = cls in TERMINAL_CLASSES

    if is_term:
        mods = "CTRL + SHIFT"
        key_map = {"shrink": "minus", "grow": "plus", "reset": "BackSpace"}
    else:
        mods = "CTRL"
        key_map = {"shrink": "minus", "grow": "plus", "reset": "0"}

    key = key_map[action]
    dispatch(f'hl.dsp.send_shortcut({{ mods = "{mods}", key = "{key}" }})')
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
