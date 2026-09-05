import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_visuals.dart';

class AiChatResultSections extends StatelessWidget {
  final Map<String, dynamic> metadata;
  final ValueChanged<String> onAskAbout;
  final ValueChanged<Map<String, dynamic>> onOpenProduct;
  final ValueChanged<Map<String, dynamic>> onOpenStore;

  const AiChatResultSections({
    super.key,
    required this.metadata,
    required this.onAskAbout,
    required this.onOpenProduct,
    required this.onOpenStore,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = _maps(metadata['products']);
    final List<Map<String, dynamic>> stores = _maps(metadata['stores']);
    final List<Map<String, dynamic>> categories = _maps(metadata['categories']);
    final Map<String, dynamic> currency = metadata['currency'] is Map
        ? Map<String, dynamic>.from(metadata['currency'] as Map)
        : const <String, dynamic>{};
    final bool isPriceComparison = metadata['comparison'] is Map;

    if (products.isEmpty && stores.isEmpty && categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (products.isNotEmpty)
          _ResultSection(
            title: isPriceComparison ? 'price_comparison'.tr : 'items'.tr,
            icon: Icons.shopping_bag_outlined,
            height: 176,
            itemCount: products.length,
            itemBuilder: (context, index) => _AnimatedResultEntry(
              index: index,
              child: _ProductResultCard(
                product: products[index],
                currency: currency,
                comparisonRank: isPriceComparison ? index + 1 : null,
                onTap: () => onOpenProduct(products[index]),
              ),
            ),
          ),
        if (stores.isNotEmpty)
          _ResultSection(
            title: 'stores'.tr,
            icon: Icons.storefront_outlined,
            height: 148,
            itemCount: stores.length,
            itemBuilder: (context, index) => _AnimatedResultEntry(
              index: index,
              child: _StoreResultCard(
                store: stores[index],
                currency: currency,
                onTap: () => onOpenStore(stores[index]),
              ),
            ),
          ),
        if (categories.isNotEmpty) ...[
          _SectionHeading(title: 'categories'.tr, icon: Icons.grid_view),
          Wrap(
            spacing: Dimensions.paddingSizeExtraSmall,
            runSpacing: Dimensions.paddingSizeExtraSmall,
            children: categories
                .map(
                  (category) => ActionChip(
                    avatar: _ResultImage(
                      image: category['image_full_url']?.toString() ?? '',
                      size: 24,
                      borderRadius: 12,
                    ),
                    label: Text(
                      category['name']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () =>
                        onAskAbout(category['name']?.toString() ?? ''),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ],
    );
  }

  List<Map<String, dynamic>> _maps(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const _ResultSection({
    required this.title,
    required this.icon,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: title, icon: icon),
        // Let the tallest card determine the row height, including scaled text.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < itemCount; index++) ...[
                    if (index > 0)
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                    itemBuilder(context, index),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    );
  }
}

class _AnimatedResultEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedResultEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: aiChatDuration(context, 220 + (index.clamp(0, 5).toInt() * 35)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(12 * (1 - value), 0),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimensions.paddingSizeExtraSmall,
        bottom: Dimensions.paddingSizeExtraSmall,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic> currency;
  final VoidCallback onTap;
  final int? comparisonRank;

  const _ProductResultCard({
    required this.product,
    required this.currency,
    required this.onTap,
    this.comparisonRank,
  });

  @override
  Widget build(BuildContext context) {
    final double price = _number(product['price']);
    final double discountedPrice = _number(product['discounted_price']);
    final bool hasDiscount =
        product['has_discount'] == true && price > discountedPrice;
    final bool inStock = product['in_stock'] != false;

    return Semantics(
      button: true,
      label: product['name']?.toString() ?? 'item'.tr,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: aiChatBorder(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 272,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResultImage(
                    image: product['image_full_url']?.toString() ?? '',
                    size: 88,
                    borderRadius: Dimensions.radiusSmall,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 3),
                        if (comparisonRank != null)
                          Text(
                            '#$comparisonRank ${comparisonRank == 1 ? 'lowest_price'.tr : 'price_comparison'.tr}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        Text(
                          product['store_name']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: aiChatMuted(context)),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: Color(0xFFF4A62A),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _number(product['rating']).toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _StockPill(inStock: inStock),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.end,
                                children: [
                                  Text(
                                    _formatMoney(discountedPrice, currency),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                  if (hasDiscount)
                                    Text(
                                      _formatMoney(price, currency),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: aiChatMuted(context),
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreResultCard extends StatelessWidget {
  final Map<String, dynamic> store;
  final Map<String, dynamic> currency;
  final VoidCallback onTap;

  const _StoreResultCard({
    required this.store,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: store['name']?.toString() ?? 'store'.tr,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: aiChatBorder(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 286,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(
                children: [
                  _ResultImage(
                    image: store['logo_full_url']?.toString() ?? '',
                    size: 76,
                    borderRadius: Dimensions.radiusDefault,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          store['name']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: Color(0xFFF4A62A),
                            ),
                            const SizedBox(width: 2),
                            Text(_number(store['rating']).toStringAsFixed(1)),
                            if ((store['delivery_time']?.toString() ?? '')
                                .isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.schedule,
                                size: 15,
                                color: aiChatMuted(context),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  store['delivery_time'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          store['free_delivery'] == true
                              ? 'free_delivery'.tr
                              : '${'min_order_of'.tr} ${_formatMoney(_number(store['minimum_order']), currency)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  final bool inStock;

  const _StockPill({required this.inStock});

  @override
  Widget build(BuildContext context) {
    final Color color = inStock
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        inStock ? 'in_stock'.tr : 'out_of_stock'.tr,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _ResultImage extends StatelessWidget {
  final String image;
  final double size;
  final double borderRadius;

  const _ResultImage({
    required this.image,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image.isEmpty
          ? Container(
              width: size,
              height: size,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(Icons.image_outlined, color: aiChatMuted(context)),
            )
          : CustomImage(image: image, width: size, height: size),
    );
  }
}

double _number(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _formatMoney(double value, Map<String, dynamic> currency) {
  final String symbol = currency['symbol']?.toString() ?? '';
  final bool right = currency['position']?.toString() == 'right';
  final String amount = value.toStringAsFixed(2);
  return right ? '$amount $symbol'.trim() : '$symbol $amount'.trim();
}
