from pathlib import Path
import re

path = Path('lib/common/widgets/item_bottom_sheet.dart')
text = path.read_text()


def replace_once(old: str, new: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'Expected one match, found {count}: {old[:80]!r}')
    text = text.replace(old, new, 1)


replace_once(
    "import 'package:sixam_mart/features/item/controllers/item_controller.dart';\n",
    "import 'package:sixam_mart/features/item/controllers/item_controller.dart';\n"
    "import 'package:sixam_mart/features/item/widgets/variation_selector_widget.dart';\n",
)

replace_once(
    """        }else {\n          List<String> variationList = [];\n          for (int index = 0; index < item.choiceOptions!.length; index++) {\n""",
    """        }else if(itemController.areVariationsSelected(item)) {\n          List<String> variationList = [];\n          for (int index = 0; index < item.choiceOptions!.length; index++) {\n""",
)

replace_once(
    """                          ) : VariationView(\n                            item: item, itemController: itemController,\n                          ),\n""",
    """                          ) : VariationSelectorWidget(\n                            item: item, itemController: itemController,\n                          ),\n""",
)

replace_once(
    """                              String? invalid;\n\n                              if(AddressHelper.getUserAddressFromSharedPref() == null) {\n""",
    """                              String? invalid;\n\n                              if(!_newVariation && !itemController.areVariationsSelected(item)) {\n                                final String? title = itemController.firstUnselectedVariationTitle(item);\n                                showCustomSnackBar(\n                                  '${'choose_a_variation_from'.tr}${title != null ? ' $title' : ''}',\n                                  getXSnackBar: true,\n                                );\n                                return;\n                              }\n\n                              if(AddressHelper.getUserAddressFromSharedPref() == null) {\n""",
)

pattern = re.compile(
    r"\nclass VariationView extends StatelessWidget \{.*?(?=\nclass NewVariationView extends StatelessWidget)",
    re.S,
)
text, count = pattern.subn("\n", text, count=1)
if count != 1:
    raise SystemExit(f'Expected one VariationView block, found {count}')

path.write_text(text)
