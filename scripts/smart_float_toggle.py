#!/usr/bin/env python3
"""Smart Super+V floating toggle for Hyprland.

- When switching a floating window back to tiled, saves its floating size/position.
- When switching a tiled window to floating, restores its saved size/position
  (clamped to stay fully inside the monitor) or defaults to a comfortable
  65% x 68% centered size so it never overflows the screen.
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from hypr_ipc import (
    batch,
    hyprctl_json,
    move_window_exact_lua,
    resize_window_exact_lua,
    toggle_floating_lua,
)

STATE_FILE = "/tmp/smart_float_state.json"
MARGIN = 24
MIN_W = 320
MIN_H = 240


def load_state():
    try:
        with open(STATE_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def save_state(state):
    try:
        with open(STATE_FILE, "w", encoding="utf-8") as f:
            json.dump(state, f, indent=2)
    except Exception:
        pass


def get_monitor_bounds(monitor_id):
    monitors = hyprctl_json(["monitors"]) or []
    mon = next((m for m in monitors if m.get("id") == monitor_id), None)
    if not mon and monitors:
        mon = next((m for m in monitors if m.get("focused")), monitors[0])
    if not mon:
        return 0, 0, 1920, 1080

    scale = mon.get("scale") or 1.0
    mx = mon.get("x", 0)
    my = mon.get("y", 0)
    mw = int(mon.get("width", 1920) / scale)
    mh = int(mon.get("height", 1080) / scale)
    res = mon.get("reserved", [0, 0, 0, 0])  # [left, top, right, bottom]
    ux = mx + res[0]
    uy = my + res[1]
    uw = max(MIN_W + 2 * MARGIN, mw - res[0] - res[2])
    uh = max(MIN_H + 2 * MARGIN, mh - res[1] - res[3])
    return ux, uy, uw, uh


def clamp_geometry(x, y, w, h, ux, uy, uw, uh):
    max_w = max(MIN_W, uw - 2 * MARGIN)
    max_h = max(MIN_H, uh - 2 * MARGIN)
    cw = max(MIN_W, min(int(w), max_w))
    ch = max(MIN_H, min(int(h), max_h))
    cx = max(ux + MARGIN, min(int(x), ux + uw - cw - MARGIN))
    cy = max(uy + MARGIN, min(int(y), uy + uh - ch - MARGIN))
    return cx, cy, cw, ch


def main():
    win = hyprctl_json(["activewindow"])
    if not win or not win.get("address"):
        return

    addr = win["address"]
    is_floating = bool(win.get("floating", False))
    state = load_state()

    if is_floating:
        # Save current floating geometry before returning to tiled
        at = win.get("at", [0, 0])
        size = win.get("size", [800, 600])
        state[addr] = {
            "x": at[0],
            "y": at[1],
            "w": size[0],
            "h": size[1],
        }
        save_state(state)
        batch([toggle_floating_lua(addr)])
        return

    ux, uy, uw, uh = get_monitor_bounds(win.get("monitor"))
    saved = state.get(addr)

    if saved and "w" in saved and "h" in saved:
        tx, ty, tw, th = clamp_geometry(
            saved.get("x", ux + MARGIN),
            saved.get("y", uy + MARGIN),
            saved["w"],
            saved["h"],
            ux,
            uy,
            uw,
            uh,
        )
    else:
        tw = int(uw * 0.65)
        th = int(uh * 0.68)
        tx = ux + (uw - tw) // 2
        ty = uy + (uh - th) // 2
        tx, ty, tw, th = clamp_geometry(tx, ty, tw, th, ux, uy, uw, uh)

    batch([
        toggle_floating_lua(addr),
        resize_window_exact_lua(tw, th, addr),
        move_window_exact_lua(tx, ty, addr),
    ])


if __name__ == "__main__":
    main()
