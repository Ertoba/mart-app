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

  @override
  Widget build(BuildContext context) {
    final List<ChoiceOptions> choices = item.choiceOptions ?? <ChoiceOptions>[];
    if (choices.isEmpty) {
      return const SizedBox();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      itemCount: choices.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: Dimensions.paddingSizeDefault),
      itemBuilder: (context, index) {
        final ChoiceOptions choice = choices[index];
        final List<String> options = choice.options ?? <String>[];
        final bool confirmed =
            itemController.isVariationSelectionConfirmed(index);
        final int selectedIndex = itemController.variationIndex != null &&
                index < itemController.variationIndex!.length
            ? itemController.variationIndex![index]
            : 0;
        final bool hasValidSelection = confirmed &&
            selectedIndex >= 0 &&
            selectedIndex < options.length;
        final String value = hasValidSelection
            ? options[selectedIndex].trim()
            : 'select_one'.tr;

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
                          attributeIndex: index,
                          title: choice.title ?? '',
                          options: options,
                          selectedIndex:
                              hasValidSelection ? selectedIndex : null,
                        ),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(
                      color: hasValidSelection
                          ? Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.55)
                          : Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.55),
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
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final int? picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) => _VariationOptionsSheet(
        title: title,
        options: options,
        selectedIndex: selectedIndex,
      ),
    );

    if (picked != null && context.mounted) {
      itemController.setCartVariationIndex(attributeIndex, picked, item);
    }
  }
}

class _VariationOptionsSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final int? selectedIndex;

  const _VariationOptionsSheet({
    required this.title,
    required this.options,
    required this.selectedIndex,
  });

  @override
  State<_VariationOptionsSheet> createState() =>
      _VariationOptionsSheetState();
}

class _VariationOptionsSheetState extends State<_VariationOptionsSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

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
    final List<MapEntry<int, String>> visibleOptions = widget.options
        .asMap()
        .entries
        .where(
          (entry) => normalizedQuery.isEmpty ||
              entry.value.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);

    final double heightFactor = widget.options.length >= 12
        ? 0.82
        : widget.options.length >= 7
            ? 0.72
            : widget.options.length >= 4
                ? 0.58
                : 0.44;

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.55),
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
                              fillColor: Theme.of(context)
                                  .disabledColor
                                  .withValues(alpha: 0.06),
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
                          : ListView.separated(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.fromLTRB(
                                Dimensions.paddingSizeDefault,
                                0,
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeDefault,
                              ),
                              itemCount: visibleOptions.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.16),
                              ),
                              itemBuilder: (context, listIndex) {
                                final MapEntry<int, String> entry =
                                    visibleOptions[listIndex];
                                final bool selected =
                                    entry.key == widget.selectedIndex;

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    onTap: () => Navigator.of(context)
                                        .pop(entry.key),
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(minHeight: 52),
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
                                                overflow: TextOverflow.ellipsis,
                                                style: selected
                                                    ? robotoMedium
                                                    : robotoRegular,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: Dimensions.paddingSizeSmall,
                                            ),
                                            if (selected)
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                size: 22,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
