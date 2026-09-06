import 'package:sixam_mart/util/typography.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final String? image;
  final String? lottieAsset;
  final double iconSize;
  final double? titleFontSize;
  final double? seeAllFontSize;
  final bool seeAllUnderline;
  const TitleWidget({
    super.key,
    required this.title,
    this.onTap,
    this.image,
    this.lottieAsset,
    this.iconSize = 20,
    this.titleFontSize,
    this.seeAllFontSize,
    this.seeAllUnderline = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    final bool isCompactPhone = !ResponsiveHelper.isDesktop(context) && MediaQuery.sizeOf(context).width < 430;
    final double resolvedTitleFontSize = titleFontSize ?? (isCompactPhone ? Dimensions.fontSizeDefault : Dimensions.fontSizeLarge);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  semanticsLabel: title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MiliTypography.heading.copyWith(
                    fontSize: resolvedTitleFontSize,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              lottieAsset != null
                  ? Lottie.asset(
                      lottieAsset!,
                      height: iconSize,
                      width: iconSize,
                      fit: BoxFit.contain,
                      decoder: lottieAsset!.toLowerCase().endsWith('.lottie')
                          ? _decodeDotLottie
                          : null,
                    )
                  : image != null
                  ? Image.asset(image!, height: iconSize, width: iconSize)
                  : const SizedBox(),
            ],
          ),
        ),
        (onTap != null)
            ? InkWell(
                onTap: onTap as void Function()?,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    ltr ? 10 : 0,
                    5,
                    ltr ? 0 : 10,
                    5,
                  ),
                  child: Text(
                    'see_all'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: (seeAllFontSize ?? Dimensions.fontSizeSmall),
                      height: 1.2,
                      color: Theme.of(context).primaryColor,
                      decoration: seeAllUnderline
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  static Future<LottieComposition?> _decodeDotLottie(List<int> bytes) {
    return LottieComposition.decodeZip(
      bytes,
      filePicker: (files) {
        for (final file in files) {
          final String name = file.name.toLowerCase();
          if (name.startsWith('animations/') && name.endsWith('.json')) {
            return file;
          }
        }
        return null;
      },
    );
  }
}
