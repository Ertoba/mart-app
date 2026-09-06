import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class PortionWidget extends StatelessWidget {
  final String icon;
  final IconData? materialIcon;
  final String title;
  final bool hideDivider;
  final String route;
  final String? suffix;
  final Function()? onTap;
  const PortionWidget({
    super.key,
    required this.icon,
    this.materialIcon,
    required this.title,
    required this.route,
    this.hideDivider = false,
    this.suffix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompactPhone = MediaQuery.sizeOf(context).width < 430;

    return InkWell(
      onTap: onTap ?? () => Get.toNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
        ),
        child: Column(
          children: [
            Row(
              children: [
                materialIcon != null
                    ? Icon(
                        materialIcon,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                      )
                    : Image.asset(
                        icon,
                        height: 16,
                        width: 16,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                      ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: isCompactPhone ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
                      height: 1.2,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                suffix != null
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall,
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: Text(
                          suffix!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.2,
                            color: Colors.white,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            hideDivider ? const SizedBox() : const Divider(),
          ],
        ),
      ),
    );
  }
}
