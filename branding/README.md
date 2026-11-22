# MILI launcher identity

The existing [MILI vector](./mili-mark.svg) is unchanged. All three mobile
repositories use the same generator, green #009956, flat white background,
geometry and bundled [Noto Sans Georgian SemiBold](../assets/font/noto/NotoSansGeorgian-SemiBold.ttf).
Only [icon-config.json](./icon-config.json) changes the caption: none for
Customer, `ვენდორი` for Vendor and `კურიერი` for Courier.

The logo occupies 46% of Android's 108dp adaptive layer (69% of the 72dp visible
viewport). Its centre is always at x=50%, y=47%; adding a caption never scales
or shifts it. Captions use 7.3%-of-layer font size in the reserved lower area.
All visible content fits the central 66dp guaranteed-safe circle. Legacy,
round, iOS and web icons use the same visible-viewport crop. iOS images are RGB
without transparency. Android adaptive foregrounds stay transparent.

Run from the repository root with Python 3 and pinned Pillow:

```sh
python -m pip install -r branding/requirements.txt
python branding/build_assets.py --icons-only
python branding/test_branding.py
```

Canonical previews are [launcher-icon.png](./launcher-icon.png) and
[launcher-foreground.png](./launcher-foreground.png). The icon-only command does
not touch in-app logos or splash assets. The existing default command still
regenerates aspect-preserving in-app and launch images; it never stretches the
vector. No AI-generated artwork, replacement mark or private license source is
used.

The brand GitHub workflow validates committed icon assets with read-only
permissions. It never auto-commits generated logos or moves main during a
release build. Use the existing `--android-only` option for Android-only updates.
