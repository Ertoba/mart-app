import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;
  final bool isBorder;
  final Color? iconColor;
  final TextStyle? textStyle;
  const CustomButton({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin,
    this.width,
    this.height,
    this.fontSize,
    this.radius = 10,
    this.icon,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.isBold = true,
    this.isBorder = false,
    this.iconColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null
          ? const Color(0xff93A2AE)
          : transparent
          ? Colors.transparent
          : color ?? Theme.of(context).primaryColor,
      minimumSize: Size(width ?? Dimensions.webMaxWidth, height ?? 50),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: isBorder
            ? BorderSide(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
              )
            : BorderSide.none,
      ),
    );

    return Center(
      child: SizedBox(
        width: width ?? Dimensions.webMaxWidth,
        child: Padding(
          padding: margin ?? EdgeInsets.zero,
          child: TextButton(
            onPressed: isLoading ? null : onPressed as void Function()?,
            style: flatButtonStyle,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Keep the label's layout while busy so the action never jumps.
                ExcludeSemantics(
                  excluding: isLoading,
                  child: Opacity(
                    opacity: isLoading ? 0 : 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color:
                                iconColor ??
                                (transparent
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).cardColor),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),
                        ],
                        Flexible(
                          child: Text(
                            buttonText,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                (textStyle ??
                                        (isBold ? robotoBold : robotoRegular)
                                            .copyWith(
                                              color:
                                                  textColor ??
                                                  (transparent
                                                      ? Theme.of(
                                                          context,
                                                        ).primaryColor
                                                      : Colors.white),
                                              fontSize:
                                                  fontSize ??
                                                  Dimensions.fontSizeLarge,
                                            ))
                                    .copyWith(height: textStyle?.height ?? 1.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Semantics(
                      label: 'loading'.tr,
                      liveRegion: true,
                      child: Center(
                        child: MediaQuery.disableAnimationsOf(context)
                            ? Icon(
                                Icons.hourglass_top_rounded,
                                color:
                                    textColor ??
                                    (transparent
                                        ? Theme.of(context).primaryColor
                                        : Colors.white),
                                size: 20,
                              )
                            : SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color:
                                      textColor ??
                                      (transparent
                                          ? Theme.of(context).primaryColor
                                          : Colors.white),
                                  strokeWidth: 2,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
