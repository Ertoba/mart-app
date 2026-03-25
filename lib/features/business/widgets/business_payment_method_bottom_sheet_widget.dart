import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/business/controllers/business_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BusinessPaymentMethodBottomSheetWidget extends StatelessWidget {
  const BusinessPaymentMethodBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final methods = Get.find<SplashController>().configModel?.activePaymentMethodList ?? [];

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: SafeArea(
        top: false,
        child: GetBuilder<BusinessController>(
          builder: (businessController) {
            return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('select_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              if(methods.isEmpty)
                Text(
                  'no_payment_method_found'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                ),
              if(methods.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: methods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    final method = methods[index];
                    final bool isSelected = businessController.digitalPaymentName == method.getWay;
                    return InkWell(
                      onTap: () {
                        businessController.setPaymentIndex(1);
                        businessController.changeDigitalPaymentName(method.getWay);
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                              method.getWayTitle ?? method.getWay ?? 'payment',
                              style: robotoMedium.copyWith(
                                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          if(isSelected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                        ]),
                      ),
                    );
                  },
                ),
            ]);
          },
        ),
      ),
    );
  }
}
