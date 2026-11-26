#!/usr/bin/env python3
"""Capture a Wallpaper Engine scene as high-quality MP4/GIF and set it via mpvpaper."""

import argparse
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time

WALLPAPERS_DIR = "/home/cian/Wallpapers"
STEAM_WE_DIR = os.path.expanduser("~/.local/share/Steam/steamapps/workshop/content/431960")
ASSETS_DIR = os.path.expanduser("~/.local/share/wallpaper_engine/assets")
SCREEN = "eDP-1"


def notify(msg: str, color: str = "rgb(89b4fa)", ms: int = 3000) -> None:
    subprocess.run(["hyprctl", "notify", "-1", str(ms), color, msg], check=False)


def dmenu(items: list[str], prompt: str) -> str:
    launcher = (
        ["wofi", "--dmenu", "--prompt", prompt]
        if shutil.which("wofi")
        else ["rofi", "-dmenu", "-p", prompt]
    )
    res = subprocess.run(launcher, input="\n".join(items), text=True, capture_output=True)
    return res.stdout.strip()


def discover_scenes() -> list[tuple[str, str, str]]:
    """Return list of (label, safe_slug, folder_path) across Wallpapers and Steam Workshop."""
    seen_ids = set()
    scenes = []
    for base in (WALLPAPERS_DIR, STEAM_WE_DIR):
        if not os.path.isdir(base):
            continue
        for entry in sorted(os.listdir(base)):
            folder = os.path.join(base, entry)
            proj = os.path.join(folder, "project.json")
            if not (os.path.isdir(folder) and os.path.isfile(proj)):
                continue
            if entry in seen_ids:
                continue
            seen_ids.add(entry)
            title = entry
            wtype = "scene"
            try:
                with open(proj, "r", encoding="utf-8", errors="ignore") as f:
                    data = json.load(f)
                title = data.get("title") or entry
                wtype = data.get("type") or "scene"
            except Exception:
                pass
            slug = re.sub(r"[^a-zA-Z0-9_-]+", "_", title).strip("_").lower() or entry
            label = f"[{wtype}] {title} ({entry})"
            scenes.append((label, f"{slug}_{entry}", folder))
    return scenes


def get_active_workspace_id() -> int:
    raw = subprocess.check_output(["hyprctl", "activeworkspace", "-j"], text=True)
    return int(json.loads(raw)["id"])


def switch_workspace(ws_id: int) -> None:
    subprocess.run(
        ["hyprctl", "eval", f"hl.dsp.focus({{ workspace = {ws_id} }})"],
        capture_output=True,
        check=False,
    )


def stop_wallpapers() -> None:
    subprocess.run(["pkill", "-x", "mpvpaper"], capture_output=True)
    subprocess.run(["pkill", "-f", "linux-wallpaperengine"], capture_output=True)


def launch_mpvpaper(path: str) -> None:
    stop_wallpapers()
    subprocess.Popen(
        ["mpvpaper", "-o", "no-audio loop", SCREEN, path],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def capture_scene(
    folder: str,
    slug: str,
    fmt: str,
    duration: int,
    fps: int,
    apply_after: bool,
) -> list[str]:
    os.makedirs(WALLPAPERS_DIR, exist_ok=True)
    orig_ws = get_active_workspace_id()
    stop_wallpapers()

    lwe_cmd = [
        "linux-wallpaperengine",
        "--screen-root", SCREEN,
        "--fps", str(fps),
        "--silent",
        "--no-fullscreen-pause",
        "--bg", folder,
    ]
    if os.path.isdir(ASSETS_DIR):
        lwe_cmd.extend(["--assets-dir", ASSETS_DIR])

    lwe_proc = subprocess.Popen(lwe_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    outputs: list[str] = []

    with tempfile.TemporaryDirectory(prefix="we_cap_") as tmpdir:
        raw_mp4 = os.path.join(tmpdir, "raw.mp4")
        palette_png = os.path.join(tmpdir, "palette.png")
        try:
            # Switch to an empty workspace so no windows obstruct the capture
            switch_workspace(99)
            time.sleep(2.2)

            notify(f"Capturando Wallpaper Engine ({duration}s @ {fps}fps)...", ms=2500)
            rec_proc = subprocess.Popen(
                [
                    "wf-recorder",
                    "-o", SCREEN,
                    "-r", str(fps),
                    "-c", "libx264",
                    "-p", "crf=12",
                    "-p", "preset=ultrafast",
                    "-f", raw_mp4,
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            time.sleep(duration)
            rec_proc.send_signal(signal.SIGINT)
            rec_proc.wait(timeout=10)
        finally:
            switch_workspace(orig_ws)
            lwe_proc.terminate()
            try:
                lwe_proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                lwe_proc.kill()

        if not os.path.isfile(raw_mp4):
            raise RuntimeError("wf-recorder no generó el archivo de captura.")

        notify("Procesando en alta calidad con ffmpeg...", ms=2500)

        if fmt in ("mp4", "both"):
            out_mp4 = os.path.join(WALLPAPERS_DIR, f"{slug}.mp4")
            subprocess.run(
                [
                    "ffmpeg", "-y",
                    "-i", raw_mp4,
                    "-c:v", "libx264",
                    "-crf", "16",
                    "-preset", "slow",
                    "-pix_fmt", "yuv420p",
                    "-movflags", "+faststart",
                    out_mp4,
                ],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            outputs.append(out_mp4)

        if fmt in ("gif", "both"):
            out_gif = os.path.join(WALLPAPERS_DIR, f"{slug}.gif")
            vf_palette = "fps=24,scale=1280:-1:flags=lanczos,palettegen=stats_mode=diff"
            subprocess.run(
                ["ffmpeg", "-y", "-i", raw_mp4, "-vf", vf_palette, palette_png],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            vf_use = "fps=24,scale=1280:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5"
            subprocess.run(
                [
                    "ffmpeg", "-y",
                    "-i", raw_mp4,
                    "-i", palette_png,
                    "-lavfi", vf_use,
                    out_gif,
                ],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            outputs.append(out_gif)

    if apply_after and outputs:
        # Prefer MP4 for mpvpaper if both were generated (lowest CPU/RAM)
        target = next((p for p in outputs if p.endswith(".mp4")), outputs[0])
        launch_mpvpaper(target)

    notify(f"Wallpaper capturado y aplicado: {os.path.basename(outputs[0])}", "rgb(a6e3a1)", 4000)
    return outputs


def main() -> int:
    parser = argparse.ArgumentParser(description="Capture Wallpaper Engine as MP4/GIF.")
    parser.add_argument("--id", help="Workshop ID or folder name to capture non-interactively")
    parser.add_argument("--format", choices=["mp4", "gif", "both"], help="Output format")
    parser.add_argument("--duration", type=int, default=15, help="Capture duration in seconds")
    parser.add_argument("--fps", type=int, default=60, help="Capture FPS (default: 60)")
    parser.add_argument("--no-apply", action="store_true", help="Do not auto-apply with mpvpaper")
    args = parser.parse_args()

    scenes = discover_scenes()
    if not scenes:
        print("No se encontraron escenas de Wallpaper Engine.", file=sys.stderr)
        return 1

    if args.id:
        match = next((s for s in scenes if os.path.basename(s[2]) == args.id), None)
        if not match:
            print(f"No se encontró la escena con ID: {args.id}", file=sys.stderr)
            return 1
        _, slug, folder = match
        fmt = args.format or "mp4"
        dur = args.duration
    else:
        choice = dmenu([s[0] for s in scenes], "Capturar Wallpaper Engine")
        if not choice:
            return 0
        match = next(s for s in scenes if s[0] == choice)
        _, slug, folder = match

        fmt_choice = dmenu(
            [
                "mp4 (Video 1080p 60fps - Máxima calidad y mínimo consumo)",
                "gif (GIF animado HD 24fps)",
                "both (Ambos: MP4 + GIF)",
            ],
            "Formato de salida",
        )
        if not fmt_choice:
            return 0
        fmt = fmt_choice.split()[0]

        dur_choice = dmenu(["10", "15", "20", "30"], "Duración (segundos)")
        if not dur_choice:
            return 0
        dur = int(dur_choice)

    outputs = capture_scene(
        folder=folder,
        slug=slug,
        fmt=fmt,
        duration=dur,
        fps=args.fps,
        apply_after=not args.no_apply,
    )
    for out in outputs:
        print(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
