import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DeliveryInstractionBottomSheetWidget extends StatelessWidget {
  const DeliveryInstractionBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: 500),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: GetBuilder<CheckoutController>(
        builder: (checkoutController) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('add_more_delivery_instruction'.tr, style: robotoMedium),
                  IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
                ],
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AppConstants.deliveryInstructionList.length,
                  itemBuilder: (context, index) {
                    final isSelected = checkoutController.selectedInstruction == index;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(AppConstants.deliveryInstructionList[index].tr),
                      trailing: Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off),
                      onTap: () {
                        checkoutController.setInstruction(index);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
