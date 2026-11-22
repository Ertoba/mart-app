#!/usr/bin/env python3
"""Focused deterministic launcher-identity checks; no Flutter build needed."""
import hashlib
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

import build_assets as branding


class LauncherBrandingTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mark = branding.master_logo()
        cls.config = branding.icon_config()
        cls.master = branding.adaptive_master(cls.mark, cls.config["caption"])

    def test_caption_layout_does_not_depend_on_optional_raqm(self):
        with patch.object(branding.ImageFont, 'truetype', wraps=branding.ImageFont.truetype) as loader:
            branding.adaptive_master(self.mark, '\u10d9\u10e3\u10e0\u10d8\u10d4\u10e0\u10d8')
        self.assertEqual(loader.call_args.kwargs['layout_engine'], branding.ImageFont.Layout.BASIC)

    def test_original_mili_mark_and_georgian_font_are_unchanged(self):
        self.assertEqual(
            hashlib.sha256(branding.SVG.read_bytes()).hexdigest(),
            "c36de3a4a86b9be5f8d7b596c317447073447814454920543a958bc8a8906917",
        )
        self.assertEqual(
            hashlib.sha256(branding.FONT.read_bytes()).hexdigest(),
            "3733a66d89a3db010b1c889f170fe888c1b35042d19c73e64b74b51ef97f1346",
        )

    def test_role_caption_does_not_resize_or_shift_green_mark(self):
        plain = branding.adaptive_master(self.mark, "")
        until_caption = round(branding.MASTER_SIZE * branding.CAPTION_TOP)
        self.assertEqual(
            self.master.crop((0, 0, branding.MASTER_SIZE, until_caption)).tobytes(),
            plain.crop((0, 0, branding.MASTER_SIZE, until_caption)).tobytes(),
        )
        caption_area = self.master.crop(
            (0, until_caption, branding.MASTER_SIZE, branding.MASTER_SIZE)
        )
        self.assertEqual(bool(caption_area.getbbox()), bool(self.config["caption"]))

    def test_complete_artwork_fits_guaranteed_android_safe_circle(self):
        size = branding.MASTER_SIZE
        radius = size * 66 / 108 / 2
        safe = Image.new("L", (size, size), 0)
        ImageDraw.Draw(safe).ellipse(
            (size / 2 - radius, size / 2 - radius,
             size / 2 + radius, size / 2 + radius), fill=255,
        )
        outside = ImageChops.subtract(self.master.getchannel("A"), safe)
        self.assertIsNone(outside.getbbox(), "Logo or Georgian role would be clipped")

    def test_canonical_icons_are_reproducible(self):
        for name, expected in (
            ("launcher-icon.png", branding.icon_image(self.master, 1024, rgb=True)),
            ("launcher-foreground.png", branding.icon_image(self.master, 432, adaptive=True)),
        ):
            with Image.open(branding.ROOT / "branding" / name) as actual:
                self.assertEqual(actual.mode, expected.mode)
                self.assertEqual(actual.tobytes(), expected.tobytes(), name)

    def test_every_android_density_uses_identical_geometry(self):
        base = branding.ROOT / "android/app/src/main/res"
        for density, size in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
                              ("xxhdpi", 144), ("xxxhdpi", 192)):
            for name, expected in (
                ("ic_launcher.png", branding.icon_image(self.master, size)),
                ("ic_launcher_round.png", branding.icon_image(self.master, size, round_icon=True)),
                ("ic_launcher_foreground.png",
                 branding.icon_image(self.master, round(size * 2.25), adaptive=True)),
            ):
                with Image.open(base / f"mipmap-{density}" / name) as actual:
                    self.assertEqual(actual.tobytes(), expected.tobytes(), f"{density}/{name}")

    def test_adaptive_xml_and_round_manifest_are_present(self):
        base = branding.ROOT / "android/app/src/main"
        ns = "{http://schemas.android.com/apk/res/android}"
        app = ET.parse(base / "AndroidManifest.xml").find("application")
        self.assertEqual(app.attrib[ns + "icon"], "@mipmap/ic_launcher")
        self.assertEqual(app.attrib[ns + "roundIcon"], "@mipmap/ic_launcher_round")
        for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
            root = ET.parse(base / "res/mipmap-anydpi-v26" / name).getroot()
            self.assertEqual(root.tag, "adaptive-icon")
            self.assertEqual(root.find("foreground").attrib[ns + "drawable"],
                             "@mipmap/ic_launcher_foreground")

    def test_ios_icons_are_flat_square_rgb_and_reproducible(self):
        icons = branding.ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
        for path in icons.glob("*.png"):
            with Image.open(path) as actual:
                self.assertEqual(actual.width, actual.height, path.name)
                self.assertEqual(actual.mode, "RGB", path.name)
                self.assertEqual(
                    actual.tobytes(),
                    branding.icon_image(self.master, actual.width, rgb=True).tobytes(),
                    path.name,
                )


if __name__ == "__main__":
    unittest.main(verbosity=2)
