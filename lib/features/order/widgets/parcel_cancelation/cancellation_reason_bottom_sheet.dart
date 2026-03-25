import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/util/dimensions.dart';

class CancellationReasonBottomSheet extends StatelessWidget {
  final bool isBeforePickup;
  final int? orderId;
  final String? contactNumber;
  final bool chargePayerSender;
  final double orderAmount;
  final double dmTips;

  const CancellationReasonBottomSheet({
    super.key,
    required this.isBeforePickup,
    required this.orderId,
    required this.contactNumber,
    required this.chargePayerSender,
    required this.orderAmount,
    required this.dmTips,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('cancel_delivery'.tr),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomButton(buttonText: 'close'.tr, onPressed: Get.back),
        ],
      ),
    );
  }
}
