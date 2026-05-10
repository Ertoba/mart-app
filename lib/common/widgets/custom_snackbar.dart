import 'package:sixam_mart/common/widgets/coustom_toast.dart';
import 'package:sixam_mart/helper/server_message_translator.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = false,
  int? showDuration,
  double? bottomMargin,
}) {
  if (message != null && message.isNotEmpty) {
    final String displayMessage = ServerMessageTranslator.translate(message);
    if (getXSnackBar) {
      Get.showSnackbar(
        GetSnackBar(
          backgroundColor: Colors.transparent,
          messageText: CustomToast(text: displayMessage, isError: isError),
          maxWidth: 500,
          duration: Duration(seconds: showDuration ?? 3),
          snackStyle: SnackStyle.FLOATING,
          margin: EdgeInsets.only(
            left: Dimensions.paddingSizeSmall,
            right: Dimensions.paddingSizeSmall,
            bottom: bottomMargin ?? 100,
          ),
          borderRadius: 50,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.endToStart,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          content: CustomToast(text: displayMessage, isError: isError),
          duration: Duration(seconds: showDuration ?? 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
