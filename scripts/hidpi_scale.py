#!/usr/bin/env python3
"""Dynamic HiDPI monitor scaling for Hyprland (up, down, reset)."""

import json
import subprocess
import sys
from pathlib import Path

SCALES = [0.75, 0.8, 0.9, 1.0, 1.2, 1.25, 1.5, 1.75, 2.0]
DEFAULT_SCALE = 1.25
XRESOURCES = Path.home() / ".Xresources"


def get_focused_monitor() -> dict:
    raw = subprocess.check_output(["hyprctl", "monitors", "-j"], text=True)
    monitors = json.loads(raw)
    for mon in monitors:
        if mon.get("focused"):
            return mon
    return monitors[0]


def pick_next_scale(current: float, action: str) -> float:
    if action == "reset":
        return DEFAULT_SCALE
    nearest_idx = min(range(len(SCALES)), key=lambda i: abs(SCALES[i] - current))
    if action == "down":
        return SCALES[max(0, nearest_idx - 1)]
    if action == "up":
        return SCALES[min(len(SCALES) - 1, nearest_idx + 1)]
    raise ValueError(f"Unknown action: {action}")


def update_xft_dpi(scale: float) -> None:
    dpi = max(72, round(96 * scale))
    if XRESOURCES.exists():
        lines = XRESOURCES.read_text().splitlines()
        out = []
        replaced = False
        for line in lines:
            if line.strip().startswith("Xft.dpi:"):
                out.append(f"Xft.dpi: {dpi}")
                replaced = True
            else:
                out.append(line)
        if not replaced:
            out.insert(0, f"Xft.dpi: {dpi}")
        XRESOURCES.write_text("\n".join(out) + "\n")
    else:
        XRESOURCES.write_text(f"Xft.dpi: {dpi}\n")
    subprocess.run(["xrdb", "-merge", str(XRESOURCES)], check=False)


def main() -> int:
    action = sys.argv[1] if len(sys.argv) > 1 else "reset"
    if action not in ("up", "down", "reset"):
        print("Usage: hidpi_scale.py [up|down|reset]", file=sys.stderr)
        return 1

    mon = get_focused_monitor()
    name = mon["name"]
    current = float(mon["scale"])
    new_scale = pick_next_scale(current, action)

    mode = f"{mon['width']}x{mon['height']}@{round(mon['refreshRate'])}"
    pos = f"{mon['x']}x{mon['y']}"
    lua_cmd = (
        f'hl.monitor({{ output = "{name}", mode = "{mode}", '
        f'position = "{pos}", scale = {new_scale} }})'
    )
    subprocess.run(["hyprctl", "eval", lua_cmd], check=True)
    update_xft_dpi(new_scale)
    subprocess.run(
        [
            "hyprctl",
            "notify",
            "-1",
            "1500",
            "rgb(89b4fa)",
            f"HiDPI ({name}): {new_scale}x",
        ],
        check=False,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
