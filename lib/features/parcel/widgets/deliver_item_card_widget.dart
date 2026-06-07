import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

IconData? parcelIconForCategory(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('დოკუმ') || normalized.contains('document')) return Icons.description_outlined;
  if (normalized.contains('საჩუქ') || normalized.contains('gift')) return Icons.card_giftcard_outlined;
  if (normalized.contains('მედ') || normalized.contains('medicine')) return Icons.medical_services_outlined;
  if (normalized.contains('სახლ') || normalized.contains('home')) return Icons.home_outlined;
  if (normalized.contains('ბიზნეს') || normalized.contains('business')) return Icons.handshake_outlined;
  if (normalized.contains('საკვ') || normalized.contains('food')) return Icons.room_service_outlined;
  return null;
}

class DeliverItemCardWidget extends StatelessWidget {
  final String image;
  final String itemName;
  final String description;
  final bool isDeliverItem;
  final Function? onTap;
  const DeliverItemCardWidget({super.key, required this.image, required this.itemName, required this.description, this.isDeliverItem = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final IconData? iconData = parcelIconForCategory(itemName);
    final Color iconColor = Theme.of(context).primaryColor;
    Widget categoryVisual({required double size}) => iconData != null
        ? Icon(iconData, size: size, color: iconColor)
        : CustomImage(image: image, height: size, width: size, fit: BoxFit.contain);

    return Container(
      padding: EdgeInsets.all(isDeliverItem ? 0 : Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: isDeliverItem ? null : Border.all(color: Theme.of(context).disabledColor, width: 0.5),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: isDeliverItem ? [BoxShadow(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
          spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1), // changes position of shadow
        )] : null,
      ),
      child: isDeliverItem ? CustomInkWell(
        onTap: onTap,
        radius: Dimensions.radiusDefault,
        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
        child: Column(children: [
          categoryVisual(size: 45),

          Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium),

          Text(
            description,
            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
          ),
        ]),
      ) : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        categoryVisual(size: 40),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

            Text(
              description,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
        ),

      ]),
    );
  }
}
