import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

void showCartSnackBar() {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.horizontal,
      margin: EdgeInsets.only(
        right: ResponsiveHelper.isDesktop(Get.context)
            ? Get.context!.width * 0.7
            : Dimensions.paddingSizeSmall,
        top: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeSmall,
        left: Dimensions.paddingSizeSmall,
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      content: Row(
        children: [
          Expanded(
            child: Text(
              'item_added_to_cart'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
              Get.toNamed(RouteHelper.getCartRoute());
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'view_cart'.tr,
              style: robotoMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );

  Future.delayed(Duration(seconds: 3), () {
    ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
  });
}
