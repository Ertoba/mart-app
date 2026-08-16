# Mili bitmap memory patch

This directory vendors `google_maps_flutter_android` 2.18.12. Android bitmap
bytes and assets are decoded in two passes with `BitmapFactory.Options` and a
target-aware power-of-two sample size before final marker scaling.

The public Dart API and map marker dimensions are unchanged.
