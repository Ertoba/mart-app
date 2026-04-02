import 'package:sixam_mart/common/widgets/coustom_toast.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = false,
  int? showDuration,
}) {
  if (message != null && message.isNotEmpty) {
    final String displayMessage = _normalizeSnackBarMessage(message);
    if (getXSnackBar) {
      Get.showSnackbar(
        GetSnackBar(
          backgroundColor: Colors.transparent,
          messageText: CustomToast(text: displayMessage, isError: isError),
          maxWidth: 500,
          duration: Duration(seconds: showDuration ?? 3),
          snackStyle: SnackStyle.FLOATING,
          margin: const EdgeInsets.only(
            left: Dimensions.paddingSizeSmall,
            right: Dimensions.paddingSizeSmall,
            bottom: 100,
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

String _normalizeSnackBarMessage(String? message) {
  final String fallbackMessage = 'request_failed'.tr;
  final String rawMessage = (message?.trim().isNotEmpty ?? false)
      ? message!.trim()
      : fallbackMessage;

  if (Get.locale?.languageCode != 'ka') {
    return rawMessage;
  }

  final Map<String, String> exactMatches = {
    'Phone number not found!': 'phone_number_not_found'.tr,
    'Email not found!': 'email_not_found'.tr,
    'Failed to send email.': 'failed_to_send_email'.tr,
    'Failed to send SMS.': 'failed_to_send_sms_popup'.tr,
    'Otp Successfully Sent To Your Phone':
        'otp_successfully_sent_to_your_phone'.tr,
    'Otp Successfully Sent To Your Mail':
        'otp_successfully_sent_to_your_mail'.tr,
    'Otp Successfully Sent To Your Phone and Mail':
        'otp_successfully_sent_to_your_phone_and_mail'.tr,
    'OTP found, you can proceed': 'otp_found_you_can_proceed'.tr,
    'Token found, you can proceed': 'otp_found_you_can_proceed'.tr,
    'Invalid token.': 'invalid_token_popup'.tr,
    'The selected email is invalid.': 'selected_email_is_invalid'.tr,
    'The selected phone is invalid.': 'selected_phone_is_invalid'.tr,
    'Connection to API server failed due to internet connection':
        'connection_to_api_server_failed'.tr,
    'Request failed': fallbackMessage,
  };

  if (exactMatches.containsKey(rawMessage)) {
    return exactMatches[rawMessage]!;
  }

  final RegExp requestFailedPattern = RegExp(r'^Request failed \(\d+\)$');
  if (requestFailedPattern.hasMatch(rawMessage)) {
    return fallbackMessage;
  }

  return rawMessage;
}
