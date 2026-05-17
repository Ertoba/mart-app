import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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
          SizedBox.square(
            dimension: 24,
            child: Lottie.asset(
              'assets/json/cart_success.json',
              repeat: false,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'item_added_to_cart'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: 'view_cart'.tr,
        onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
        textColor: Colors.white,
      ),
    ),
  );

  Future.delayed(Duration(seconds: 3), () {
    ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
  });
}
