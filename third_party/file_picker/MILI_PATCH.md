# Mili bitmap memory patch

This directory vendors `file_picker` 10.3.10. Its Android image-compression
path first reads image bounds and then decodes with `BitmapFactory.Options`
and a power-of-two sample size capped at a 4096-pixel working dimension.

The public Dart API and file-selection behavior are unchanged.
