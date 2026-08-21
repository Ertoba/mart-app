from pathlib import Path
import re


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected exactly one match, found {count}: {old[:100]!r}")
    path.write_text(text.replace(old, new, 1))


widget = Path('lib/features/item/widgets/variation_selector_widget.dart')
replace_once(
    widget,
    "heightFactor = (heightFactor + 0.10).clamp(0.54, 0.88);",
    "heightFactor = (heightFactor + 0.10).clamp(0.54, 0.88).toDouble();",
)

text = widget.read_text()
text = text.replace("_brandLabel(brandKey),", "_brandLabel(brandKey!),")
old_iphone = """  if (lower.contains('iphone') ||\n      lower.contains('აიფონ') ||\n      lower.contains('айфон')) {\n    return 'iphone';\n  }\n"""
new_iphone = """  if (lower.contains('iphone') ||\n      lower.contains('აიფონ') ||\n      lower.contains('айфон') ||\n      lower.contains('apple') ||\n      RegExp(r'^(1[1-7])(pro|max|promax|plus|mini|air)?$').hasMatch(compact)) {\n    return 'iphone';\n  }\n"""
if text.count(old_iphone) != 1:
    raise SystemExit('variation selector: expected one iPhone classifier block')
widget.write_text(text.replace(old_iphone, new_iphone, 1))

# Product details: 1688-style selected total. Keep the catalog/base price visible,
# but pass/show 0.00 on both ecommerce total paths until every required legacy
# variation has been explicitly selected. Other module types remain unchanged.
details = Path('lib/features/item/screens/item_details_screen.dart')
details_text = details.read_text()
old_total = ': priceWithAddons,'
new_total = ": (item.moduleType == 'ecommerce' && !itemController.areVariationsSelected(item)) ? 0 : priceWithAddons,"
if details_text.count(old_total) != 2:
    raise SystemExit(f'item details: expected two total fallbacks, found {details_text.count(old_total)}')
details.write_text(details_text.replace(old_total, new_total))

# Quick-add bottom sheet must use the same total semantics so there is no path
# that displays a selected total before a technical SKU is chosen.
sheet = Path('lib/common/widgets/item_bottom_sheet.dart')
sheet_text = sheet.read_text()
anchor = 'double withAddonCost = cost! + addonsCost;'
if sheet_text.count(anchor) != 1:
    raise SystemExit(f'item bottom sheet: expected one addon total anchor, found {sheet_text.count(anchor)}')
sheet_text = sheet_text.replace(
    anchor,
    anchor + "\n                                    final double displayTotal = (!_newVariation && item.moduleType == 'ecommerce' && !itemController.areVariationsSelected(item)) ? 0 : withAddonCost;",
    1,
)
pattern = re.compile(r'(PriceConverter\.convertAnimationPrice\(\s*)withAddonCost(\s*,)')
sheet_text, count = pattern.subn(r'\1displayTotal\2', sheet_text, count=1)
if count != 1:
    raise SystemExit(f'item bottom sheet: expected one displayed addon total, found {count}')
sheet.write_text(sheet_text)
