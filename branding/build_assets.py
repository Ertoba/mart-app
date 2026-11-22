#!/usr/bin/env python3
"""Reproduce MILI branding assets from the unchanged repository vector.

Requires Pillow only. Role captions use the repository's OFL Georgian font.
Use --icons-only for launcher/app-icon updates without touching in-app branding.
"""
from __future__ import annotations

import argparse
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SVG = ROOT / "branding/mili-mark.svg"
CONFIG = ROOT / "branding/icon-config.json"
FONT = ROOT / "assets/font/noto/NotoSansGeorgian-SemiBold.ttf"
RESAMPLE = Image.Resampling.LANCZOS
GREEN = (0, 153, 86, 255)
MASTER_SIZE = 1728
# Android adaptive icons use 108dp layers and a 72dp visible viewport. Keep
# all artwork within the central 66dp guaranteed-safe circle, including labels.
ADAPTIVE_VIEWPORT = 72 / 108
MARK_WIDTH = 0.46
MARK_CENTER_Y = 0.47
CAPTION_TOP = 0.65
CAPTION_FONT_SIZE = 0.073


def icon_config():
    config = json.loads(CONFIG.read_text(encoding="utf-8"))
    allowed = {"customer": "", "vendor": "ვენდორი", "delivery": "კურიერი"}
    if config.get("application") not in allowed:
        raise ValueError("Unknown MILI application identity")
    if config.get("caption") != allowed[config["application"]]:
        raise ValueError("Unexpected Georgian launcher caption")
    return config


def master_logo():
    """Rasterize the exact M/L/Z polygons; never distort or redraw the mark."""
    root = ET.parse(SVG).getroot()
    if root.attrib.get("viewBox") != "0 0 1536 1536":
        raise ValueError("Unexpected MILI vector viewport")
    canvas = Image.new("RGBA", (1536, 1536))
    draw = ImageDraw.Draw(canvas)
    paths = root.findall(".//{http://www.w3.org/2000/svg}path")
    if len(paths) != 3:
        raise ValueError("Unexpected MILI vector paths")
    for path in paths:
        data = path.attrib["d"]
        if re.search(r"[^MLZ0-9\s.,-]", data):
            raise ValueError("Unsupported SVG command; do not approximate curves")
        points = re.findall(r"(?:M|L)\s*(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)", data)
        if not data.rstrip().endswith("Z") or len(points) < 3:
            raise ValueError("MILI vector must contain closed polygons")
        draw.polygon([(float(x), float(y)) for x, y in points], fill=GREEN)
    bounds = canvas.getbbox()
    if not bounds:
        raise ValueError("MILI vector is empty")
    return canvas.crop(bounds)


def render(mark, size, width_frac=0.76, height_frac=0.72,
           background="transparent", round_icon=False):
    """Aspect-preserving in-app/splash logo rendering retained from the pipeline."""
    w, h = size
    rgba = (0, 0, 0, 0) if background == "transparent" else (255, 255, 255, 255)
    base = Image.new("RGBA", size, rgba)
    scale = min(w * width_frac / mark.width, h * height_frac / mark.height)
    scaled = mark.resize((max(1, round(mark.width * scale)),
                          max(1, round(mark.height * scale))), RESAMPLE)
    base.alpha_composite(scaled, ((w - scaled.width) // 2, (h - scaled.height) // 2))
    if round_icon:
        circle = Image.new("L", size, 0)
        ImageDraw.Draw(circle).ellipse((0, 0, w - 1, h - 1), fill=255)
        base.putalpha(circle)
    return base


def adaptive_master(mark, caption):
    """The same logo bounds in every app, with the role in the reserved area."""
    canvas = Image.new("RGBA", (MASTER_SIZE, MASTER_SIZE))
    width = round(MASTER_SIZE * MARK_WIDTH)
    height = round(width * mark.height / mark.width)
    scaled = mark.resize((width, height), RESAMPLE)
    canvas.alpha_composite(
        scaled,
        ((MASTER_SIZE - width) // 2, round(MASTER_SIZE * MARK_CENTER_Y - height / 2)),
    )
    if caption:
        font = ImageFont.truetype(str(FONT), round(MASTER_SIZE * CAPTION_FONT_SIZE))
        draw = ImageDraw.Draw(canvas)
        bbox = draw.textbbox((0, 0), caption, font=font)
        draw.text(
            ((MASTER_SIZE - (bbox[2] - bbox[0])) / 2 - bbox[0],
             MASTER_SIZE * CAPTION_TOP - bbox[1]),
            caption, font=font, fill=GREEN,
        )
    return canvas


def icon_image(master, size, adaptive=False, round_icon=False, rgb=False):
    if adaptive:
        image = master.resize((size, size), RESAMPLE)
    else:
        edge = round(MASTER_SIZE * ADAPTIVE_VIEWPORT)
        offset = (MASTER_SIZE - edge) // 2
        visible = master.crop((offset, offset, offset + edge, offset + edge))
        image = Image.new("RGBA", (size, size), "white")
        image.alpha_composite(visible.resize((size, size), RESAMPLE))
    if round_icon:
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
        image.putalpha(mask)
    return image.convert("RGB") if rgb else image


def save(image, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)
    print(f"generated {path.relative_to(ROOT)} {image.size}")


def build_icons(mark, android_only=False):
    config = icon_config()
    master = adaptive_master(mark, config["caption"])
    # Canonical review sources are regenerated with the platform derivatives.
    save(icon_image(master, 1024, rgb=True), ROOT / "branding/launcher-icon.png")
    save(icon_image(master, 432, adaptive=True), ROOT / "branding/launcher-foreground.png")
    android_res = ROOT / "android/app/src/main/res"
    densities = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    for density, px in densities.items():
        folder = android_res / f"mipmap-{density}"
        save(icon_image(master, px), folder / "ic_launcher.png")
        save(icon_image(master, px, round_icon=True), folder / "ic_launcher_round.png")
        save(icon_image(master, round(px * 2.25), adaptive=True),
             folder / "ic_launcher_foreground.png")

    if android_only:
        return

    ios_icons = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    if ios_icons.exists():
        for path in sorted(ios_icons.glob("*.png")):
            with Image.open(path) as existing:
                width, height = existing.size
            if width != height:
                raise ValueError(f"Non-square iOS app icon: {path}")
            # App Store icon bitmaps are flat white and have no alpha channel.
            save(icon_image(master, width, rgb=True), path)

    for name, size in (("favicon.png", 48), ("icons/Icon-192.png", 192),
                       ("icons/Icon-512.png", 512)):
        path = ROOT / "web" / name
        if path.exists():
            save(icon_image(master, size, rgb=True), path)


def build_in_app_assets(mark):
    image_dir = ROOT / "assets/image"
    dimensions = {"logo.png": (640, 320), "auth_logo.png": (640, 320),
                  "header_logo.png": (512, 256), "brand_mark.png": (512, 512),
                  "logo_icon.png": (512, 512)}
    for name, size in dimensions.items():
        path = image_dir / name
        if path.exists():
            save(render(mark, size, width_frac=0.84, height_frac=0.76), path)
    launch_dir = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    if launch_dir.exists():
        for path in sorted(launch_dir.glob("LaunchImage*.png")):
            save(render(mark, (320, 320), width_frac=0.76, height_frac=0.67), path)
    path = ROOT / "web/logo.png"
    if path.exists():
        save(render(mark, (512, 512), width_frac=0.70, height_frac=0.70,
                    background="white"), path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--icons-only", action="store_true",
                        help="Only launcher/platform icons; preserve in-app and splash assets.")
    parser.add_argument("--android-only", action="store_true",
                        help="Only Android launcher icons (legacy pipeline compatibility).")
    args = parser.parse_args()
    mark = master_logo()
    build_icons(mark, android_only=args.android_only)
    if not (args.icons_only or args.android_only):
        build_in_app_assets(mark)
    print("MILI_BRAND_ASSETS_DONE")


if __name__ == "__main__":
    main()
