import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class VariationSelectorWidget extends StatelessWidget {
  final Item item;
  final ItemController itemController;

  const VariationSelectorWidget({
    super.key,
    required this.item,
    required this.itemController,
  });

  bool get _isTechnicalModule => item.moduleType == 'ecommerce';

  @override
  Widget build(BuildContext context) {
    if (!_isTechnicalModule) {
      return const SizedBox();
    }

    final List<ChoiceOptions> choices = item.choiceOptions ?? <ChoiceOptions>[];
    if (choices.isEmpty) {
      return const SizedBox();
    }

    final List<MapEntry<int, ChoiceOptions>> indexedChoices = choices
        .asMap()
        .entries
        .toList(growable: false);
    final MapEntry<int, ChoiceOptions>? modelChoice = _isTechnicalModule
        ? _findChoice(indexedChoices, isTechnicalModelTitle)
        : null;
    final MapEntry<int, ChoiceOptions>? legacyBrandChoice =
        _isTechnicalModule && modelChoice != null
        ? _findChoice(indexedChoices, isTechnicalBrandTitle)
        : null;

    // On the technical module Brand is a model-list filter, not a shopper SKU
    // dimension. Legacy products may still have Brand stored as a variation;
    // keep that hidden index for cart/order compatibility and auto-select it
    // when the shopper picks a model.
    final List<MapEntry<int, ChoiceOptions>> visibleChoices = indexedChoices
        .where((entry) => entry.key != legacyBrandChoice?.key)
        .toList(growable: false);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      itemCount: visibleChoices.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: Dimensions.paddingSizeDefault),
      itemBuilder: (context, visibleIndex) {
        final MapEntry<int, ChoiceOptions> indexedChoice =
            visibleChoices[visibleIndex];
        final int attributeIndex = indexedChoice.key;
        final ChoiceOptions choice = indexedChoice.value;
        final List<String> options = choice.options ?? <String>[];
        final bool confirmed = itemController.isVariationSelectionConfirmed(
          attributeIndex,
        );
        final int selectedIndex =
            itemController.variationIndex != null &&
                attributeIndex < itemController.variationIndex!.length
            ? itemController.variationIndex![attributeIndex]
            : 0;
        final bool hasValidSelection =
            confirmed && selectedIndex >= 0 && selectedIndex < options.length;
        final String value = hasValidSelection
            ? options[selectedIndex].trim()
            : 'select_one'.tr;
        final bool isTechnicalModel =
            _isTechnicalModule && attributeIndex == modelChoice?.key;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              choice.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                onTap: options.isEmpty
                    ? null
                    : () => _openSelector(
                        context,
                        attributeIndex: attributeIndex,
                        title: choice.title ?? '',
                        options: options,
                        selectedIndex: hasValidSelection ? selectedIndex : null,
                        isTechnicalModel: isTechnicalModel,
                        legacyBrandAttributeIndex: legacyBrandChoice?.key,
                        legacyBrandOptions:
                            legacyBrandChoice?.value.options ?? <String>[],
                      ),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    border: Border.all(
                      color: hasValidSelection
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.55)
                          : Theme.of(
                              context,
                            ).disabledColor.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: hasValidSelection
                              ? robotoMedium
                              : robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSelector(
    BuildContext context, {
    required int attributeIndex,
    required String title,
    required List<String> options,
    required int? selectedIndex,
    required bool isTechnicalModel,
    required int? legacyBrandAttributeIndex,
    required List<String> legacyBrandOptions,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final _VariationPick? picked = await showModalBottomSheet<_VariationPick>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) => _VariationOptionsSheet(
        title: title,
        options: options,
        selectedIndex: selectedIndex,
        isTechnicalModel: isTechnicalModel,
        legacyBrandOptions: legacyBrandOptions,
      ),
    );

    if (picked != null && context.mounted) {
      final Map<int, int> selections = <int, int>{
        attributeIndex: picked.optionIndex,
      };
      if (isTechnicalModel &&
          legacyBrandAttributeIndex != null &&
          picked.legacyBrandIndex != null) {
        selections[legacyBrandAttributeIndex] = picked.legacyBrandIndex!;
      }
      itemController.setCartVariationIndexes(selections, item);
    }
  }
}

class _VariationPick {
  final int optionIndex;
  final int? legacyBrandIndex;

  const _VariationPick({required this.optionIndex, this.legacyBrandIndex});
}

class _VariationOptionsSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final int? selectedIndex;
  final bool isTechnicalModel;
  final List<String> legacyBrandOptions;

  const _VariationOptionsSheet({
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.isTechnicalModel,
    required this.legacyBrandOptions,
  });

  @override
  State<_VariationOptionsSheet> createState() => _VariationOptionsSheetState();
}

class _VariationOptionsSheetState extends State<_VariationOptionsSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedBrandKey;

  bool get _showSearch => widget.options.length >= 7;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final String normalizedQuery = _query.trim().toLowerCase();
    final List<String> brandKeys = widget.isTechnicalModel
        ? _brandKeysForOptions(widget.options)
        : <String>[];

    final List<MapEntry<int, String>> visibleOptions = widget.options
        .asMap()
        .entries
        .where((entry) {
          final String? brandKey = widget.isTechnicalModel
              ? inferTechnicalBrandKey(entry.value)
              : null;
          final bool brandMatches =
              _selectedBrandKey == null || brandKey == _selectedBrandKey;
          final bool searchMatches =
              normalizedQuery.isEmpty ||
              entry.value.toLowerCase().contains(normalizedQuery) ||
              (brandKey != null &&
                  _brandLabel(
                    brandKey,
                  ).toLowerCase().contains(normalizedQuery));
          return brandMatches && searchMatches;
        })
        .toList(growable: false);

    if (widget.isTechnicalModel && _selectedBrandKey == null) {
      visibleOptions.sort((a, b) {
        final int brandCompare = _brandOrder(
          inferTechnicalBrandKey(a.value),
        ).compareTo(_brandOrder(inferTechnicalBrandKey(b.value)));
        return brandCompare != 0 ? brandCompare : a.key.compareTo(b.key);
      });
    }

    double heightFactor = widget.options.length >= 12
        ? 0.82
        : widget.options.length >= 7
        ? 0.72
        : widget.options.length >= 4
        ? 0.58
        : 0.44;
    if (widget.isTechnicalModel && brandKeys.length > 1) {
      heightFactor = (heightFactor + 0.10).clamp(0.54, 0.88).toDouble();
    }

    return Padding(
      padding: EdgeInsets.only(top: media.padding.top + 8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).disabledColor.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeSmall,
                        Dimensions.paddingSizeSmall,
                        Dimensions.paddingSizeSmall,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isTechnicalModel && brandKeys.length > 1)
                      SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          itemCount: brandKeys.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final String? brandKey = index == 0
                                ? null
                                : brandKeys[index - 1];
                            return ChoiceChip(
                              label: Text(
                                brandKey == null
                                    ? 'all'.tr
                                    : _brandLabel(brandKey),
                                maxLines: 1,
                              ),
                              selected: _selectedBrandKey == brandKey,
                              onSelected: (_) {
                                setState(() => _selectedBrandKey = brandKey);
                              },
                            );
                          },
                        ),
                      ),
                    if (widget.isTechnicalModel && brandKeys.length > 1)
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    if (_showSearch)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          0,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeSmall,
                        ),
                        child: SizedBox(
                          height: 52,
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: 'search'.tr,
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    )
                                  : null,
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.06),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: visibleOptions.isEmpty
                          ? Center(
                              child: Text(
                                'no_data_found'.tr,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            )
                          : ListView.builder(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.fromLTRB(
                                Dimensions.paddingSizeDefault,
                                0,
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeDefault,
                              ),
                              itemCount: visibleOptions.length,
                              itemBuilder: (context, listIndex) {
                                final MapEntry<int, String> entry =
                                    visibleOptions[listIndex];
                                final String? brandKey = widget.isTechnicalModel
                                    ? inferTechnicalBrandKey(entry.value)
                                    : null;
                                final String? previousBrandKey =
                                    listIndex > 0 && widget.isTechnicalModel
                                    ? inferTechnicalBrandKey(
                                        visibleOptions[listIndex - 1].value,
                                      )
                                    : null;
                                final bool showGroupHeader =
                                    widget.isTechnicalModel &&
                                    _selectedBrandKey == null &&
                                    brandKey != null &&
                                    brandKey != previousBrandKey;
                                final bool selected =
                                    entry.key == widget.selectedIndex;
                                final int? legacyBrandIndex =
                                    widget.legacyBrandOptions.isEmpty
                                    ? null
                                    : legacyBrandIndexForTechnicalModel(
                                        entry.value,
                                        widget.legacyBrandOptions,
                                      );
                                final bool unresolvedLegacyBrand =
                                    widget.isTechnicalModel &&
                                    widget.legacyBrandOptions.length > 1 &&
                                    legacyBrandIndex == null;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showGroupHeader)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          Dimensions.paddingSizeSmall,
                                          Dimensions.paddingSizeSmall,
                                          Dimensions.paddingSizeSmall,
                                          Dimensions.paddingSizeExtraSmall,
                                        ),
                                        child: Text(
                                          _brandLabel(brandKey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: robotoMedium.copyWith(
                                            color: Theme.of(context).hintColor,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        onTap: unresolvedLegacyBrand
                                            ? null
                                            : () => Navigator.of(context).pop(
                                                _VariationPick(
                                                  optionIndex: entry.key,
                                                  legacyBrandIndex:
                                                      legacyBrandIndex,
                                                ),
                                              ),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minHeight: 52,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                              vertical:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    entry.value.trim(),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: unresolvedLegacyBrand
                                                        ? robotoRegular
                                                              .copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                              )
                                                        : selected
                                                        ? robotoMedium
                                                        : robotoRegular,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                if (selected)
                                                  Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                    size: 22,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (listIndex != visibleOptions.length - 1)
                                      Divider(
                                        height: 1,
                                        color: Theme.of(
                                          context,
                                        ).disabledColor.withValues(alpha: 0.16),
                                      ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

MapEntry<int, ChoiceOptions>? _findChoice(
  List<MapEntry<int, ChoiceOptions>> choices,
  bool Function(String?) predicate,
) {
  for (final MapEntry<int, ChoiceOptions> entry in choices) {
    if (predicate(entry.value.title)) {
      return entry;
    }
  }
  return null;
}

@visibleForTesting
bool isTechnicalBrandTitle(String? value) {
  final String normalized = _normalizeTitle(value);
  return normalized == 'brand' ||
      normalized == 'ბრენდი' ||
      normalized == 'бренд';
}

@visibleForTesting
bool isTechnicalModelTitle(String? value) {
  final String normalized = _normalizeTitle(value);
  return normalized == 'model' ||
      normalized == 'მოდელი' ||
      normalized == 'модель' ||
      normalized == 'applicablemodel' ||
      normalized == 'compatiblemodel' ||
      normalized == 'ტელეფონისმოდელი';
}

String _normalizeTitle(String? value) {
  return (value ?? '').trim().toLowerCase().replaceAll(
    RegExp(r'[\s_\-./]+'),
    '',
  );
}

List<String> _brandKeysForOptions(List<String> options) {
  final Set<String> keys = <String>{};
  for (final String option in options) {
    final String? key = inferTechnicalBrandKey(option);
    if (key != null) {
      keys.add(key);
    }
  }
  final List<String> result = keys.toList();
  result.sort((a, b) => _brandOrder(a).compareTo(_brandOrder(b)));
  return result;
}

@visibleForTesting
String? inferTechnicalBrandKey(String value) {
  final String lower = value.trim().toLowerCase();
  final String compact = lower.replaceAll(RegExp(r'[\s_\-./]+'), '');

  if (lower.contains('iphone') ||
      lower.contains('აიფონ') ||
      lower.contains('айфон') ||
      lower.contains('apple') ||
      RegExp(r'^(1[1-7])(pro|max|promax|plus|mini|air)?$').hasMatch(compact)) {
    return 'iphone';
  }
  if (lower.contains('samsung') ||
      lower.contains('სამსუნგ') ||
      lower.contains('самсунг') ||
      lower.contains('galaxy') ||
      lower.contains('გალაქსი') ||
      lower.contains('галакси') ||
      RegExp(r'^(a|m|s|f)\s?\d{2,3}\b').hasMatch(lower)) {
    return 'samsung';
  }
  if (lower.contains('redmi') ||
      lower.contains('რედმი') ||
      lower.contains('редми')) {
    return 'redmi';
  }
  if (lower.contains('poco') || lower.contains('პოკო')) {
    return 'poco';
  }
  if (lower.contains('xiaomi') ||
      lower.contains('შაომი') ||
      lower.contains('сяоми')) {
    return 'xiaomi';
  }
  if (lower.contains('honor') || lower.contains('ჰონორ')) {
    return 'honor';
  }
  if (lower.contains('huawei') || lower.contains('ჰუავეი')) {
    return 'huawei';
  }
  if (lower.contains('oppo')) {
    return 'oppo';
  }
  if (lower.contains('realme')) {
    return 'realme';
  }
  if (lower.contains('oneplus')) {
    return 'oneplus';
  }
  if (lower.contains('pixel') || lower.contains('googlepixel')) {
    return 'pixel';
  }

  // Common Samsung shorthand used by accessory wholesalers (A16, A55,
  // S24, M34, F55). Keep it after explicit brand checks.
  if (RegExp(r'^(a|m|s|f)\d{2,3}[a-z]*$').hasMatch(compact)) {
    return 'samsung';
  }
  return null;
}

@visibleForTesting
int? legacyBrandIndexForTechnicalModel(
  String model,
  List<String> legacyBrandOptions,
) {
  if (legacyBrandOptions.isEmpty) {
    return null;
  }
  if (legacyBrandOptions.length == 1) {
    return 0;
  }

  final String? modelKey = inferTechnicalBrandKey(model);
  final String normalizedModel = _normalizeTitle(model);
  for (int index = 0; index < legacyBrandOptions.length; index++) {
    final String brand = legacyBrandOptions[index];
    final String? brandKey = inferTechnicalBrandKey(brand);
    if (modelKey != null && brandKey == modelKey) {
      return index;
    }
    final String normalizedBrand = _normalizeTitle(brand);
    if (normalizedBrand.isNotEmpty &&
        normalizedModel.contains(normalizedBrand)) {
      return index;
    }
  }
  return null;
}

String _brandLabel(String key) {
  switch (key) {
    case 'iphone':
      return 'iPhone';
    case 'samsung':
      return 'Samsung';
    case 'redmi':
      return 'Redmi';
    case 'poco':
      return 'POCO';
    case 'xiaomi':
      return 'Xiaomi';
    case 'honor':
      return 'Honor';
    case 'huawei':
      return 'Huawei';
    case 'oppo':
      return 'OPPO';
    case 'realme':
      return 'realme';
    case 'oneplus':
      return 'OnePlus';
    case 'pixel':
      return 'Pixel';
    default:
      return key;
  }
}

int _brandOrder(String? key) {
  switch (key) {
    case 'iphone':
      return 0;
    case 'samsung':
      return 1;
    case 'redmi':
      return 2;
    case 'xiaomi':
      return 3;
    case 'poco':
      return 4;
    case 'honor':
      return 5;
    case 'huawei':
      return 6;
    case 'oppo':
      return 7;
    case 'realme':
      return 8;
    case 'oneplus':
      return 9;
    case 'pixel':
      return 10;
    default:
      return 99;
  }
}
