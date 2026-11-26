#!/usr/bin/env python3
"""Select and launch a video (mpvpaper) or Wallpaper Engine wallpaper from /home/cian/Wallpapers."""

import json
import os
import shutil
import subprocess
import sys

WALLPAPERS_DIR = "/home/cian/Wallpapers"
SCREEN = "eDP-1"
FPS = "30"
VIDEO_EXTS = (".mp4", ".webm", ".mkv", ".mov", ".gif")


def list_wallpapers():
    items = []
    if not os.path.isdir(WALLPAPERS_DIR):
        return items
    for entry in sorted(os.listdir(WALLPAPERS_DIR)):
        full = os.path.join(WALLPAPERS_DIR, entry)
        if os.path.isfile(full) and entry.lower().endswith(VIDEO_EXTS):
            items.append((f"[video] {entry}", "video", full))
            continue
        proj = os.path.join(full, "project.json")
        if os.path.isdir(full) and os.path.isfile(proj):
            try:
                with open(proj, "r", encoding="utf-8", errors="ignore") as f:
                    data = json.load(f)
                title = data.get("title") or entry
                wtype = data.get("type") or "scene"
                items.append((f"[{wtype}] {title} ({entry})", "lwe", full))
            except Exception:
                items.append((f"[scene] {entry}", "lwe", full))
    return items


def stop_current():
    subprocess.run(["pkill", "-x", "mpvpaper"], capture_output=True)
    subprocess.run(["pkill", "-f", "linux-wallpaperengine"], capture_output=True)


def launch_video(path):
    if not shutil.which("mpvpaper"):
        print("mpvpaper no está instalado.", file=sys.stderr)
        sys.exit(1)
    cmd = ["mpvpaper", "-o", "no-audio loop", SCREEN, path]
    subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def launch_lwe(folder):
    if not shutil.which("linux-wallpaperengine"):
        print("linux-wallpaperengine no está instalado.", file=sys.stderr)
        sys.exit(1)
    cmd = [
        "linux-wallpaperengine",
        "--screen-root", SCREEN,
        "--fps", FPS,
        "--silent",
        "--bg", folder,
    ]
    assets_dir = os.path.expanduser("~/.local/share/wallpaper_engine/assets")
    if os.path.isdir(assets_dir):
        cmd.extend(["--assets-dir", assets_dir])
    subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def main():
    items = list_wallpapers()
    if not items:
        print(f"No se encontraron wallpapers en {WALLPAPERS_DIR}", file=sys.stderr)
        sys.exit(1)

    menu_text = "\n".join(label for label, _, _ in items)
    launcher = (
        ["wofi", "--dmenu", "--prompt", "Wallpaper"]
        if shutil.which("wofi")
        else ["rofi", "-dmenu", "-p", "Wallpaper"]
    )
    res = subprocess.run(launcher, input=menu_text, text=True, capture_output=True)
    choice = res.stdout.strip()
    if not choice:
        return

    selected = next(((kind, path) for label, kind, path in items if label == choice), None)
    if not selected:
        return

    stop_current()
    kind, path = selected
    if kind == "video":
        launch_video(path)
    else:
        launch_lwe(path)


if __name__ == "__main__":
    main()
