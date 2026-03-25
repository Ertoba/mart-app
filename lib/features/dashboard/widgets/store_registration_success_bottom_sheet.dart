import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/util/dimensions.dart';

class StoreRegistrationSuccessBottomSheet extends StatelessWidget {
  const StoreRegistrationSuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('registration_successful'.tr),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomButton(buttonText: 'ok'.tr, onPressed: Get.back),
        ],
      ),
    );
  }
}
