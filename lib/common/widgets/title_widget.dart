import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final String? image;
  const TitleWidget({super.key, required this.title, this.onTap, this.image});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    final bool isCompactWidth = MediaQuery.of(context).size.width < 380;
    final double titleFontSize = ResponsiveHelper.isDesktop(context)
        ? Dimensions.fontSizeLarge
        : (onTap != null && isCompactWidth
              ? Dimensions.fontSizeDefault
              : Dimensions.fontSizeLarge);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: titleFontSize,
                    height: 1.2,
                  ),
                ),
              ),
              if (image != null) ...[
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Image.asset(
                  image!,
                  height: isCompactWidth ? 18 : 20,
                  width: isCompactWidth ? 18 : 20,
                ),
              ],
            ],
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: onTap as void Function()?,
            child: Padding(
              padding: EdgeInsets.fromLTRB(ltr ? 10 : 0, 5, ltr ? 0 : 10, 5),
              child: Text(
                'see_all'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                  decorationThickness: 1.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
