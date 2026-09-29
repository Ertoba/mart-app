import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/checkout/widgets/tips_widget.dart';

class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final double totalPrice;
  final Function(double x) onTotalChange;
  final int? storeId;
  const DeliveryManTipsSection({
    super.key,
    required this.takeAway,
    required this.tooltipController3,
    required this.totalPrice,
    required this.onTotalChange,
    this.storeId,
  });

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  @override
  Widget build(BuildContext context) {
    double total = widget.totalPrice;
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        return Column(
          children: [
            (!widget.takeAway &&
                    Get.find<SplashController>().configModel!.dmTipsStatus == 1)
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeLarge,
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('delivery_man_tips'.tr, style: robotoMedium),

                            JustTheTooltip(
                              backgroundColor: Colors.black87,
                              controller: widget.tooltipController3,
                              preferredDirection: AxisDirection.right,
                              tailLength: 14,
                              tailBaseWidth: 20,
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'
                                      .tr,
                                  style: robotoRegular.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    widget.tooltipController3.showTooltip(),
                                child: const Icon(Icons.info_outline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context) ? 80 : 62,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: AppConstants.tips.length,
                            itemBuilder: (context, index) {
                              final String tipValue = AppConstants.tips[index];
                              final double? tipAmount = double.tryParse(
                                tipValue,
                              );

                              if (tipAmount == null) {
                                return const SizedBox.shrink();
                              }
                              final bool isAlreadySelected =
                                  checkoutController.selectedTips == index;
                              return TipsWidget(
                                title: PriceConverter.convertPrice(
                                  tipAmount,
                                  forDM: true,
                                ),
                                isSelected:
                                    checkoutController.selectedTips == index,
                                isSuggested:
                                    tipValue ==
                                    checkoutController.mostDmTipAmount
                                        .toString(),
                                onTap: () async {
                                  total = total - checkoutController.tips;
                                  checkoutController.updateTips(
                                    isAlreadySelected ? -1 : index,
                                  );
                                  if (checkoutController.selectedTips != -1) {
                                    checkoutController.addTips(tipAmount);
                                  } else {
                                    checkoutController.addTips(0);
                                  }
                                  checkoutController.tipController.text =
                                      checkoutController.selectedTips != -1
                                      ? AppConstants.tips[checkoutController
                                            .selectedTips]
                                      : '';

                                  if (checkoutController.isPartialPay ||
                                      checkoutController.paymentMethodIndex ==
                                          1) {
                                    checkoutController.checkBalanceStatus(
                                      (total + checkoutController.tips),
                                      0,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),

                        ListTile(
                          onTap: () => checkoutController.toggleDmTipSave(),
                          leading: Checkbox(
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            activeColor: Theme.of(context).primaryColor,
                            value: checkoutController.isDmTipSave,
                            onChanged: (bool? isChecked) =>
                                checkoutController.toggleDmTipSave(),
                          ),
                          title: Text(
                            'save_for_later'.tr,
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(
                            horizontal: 0,
                            vertical: -4,
                          ),
                          dense: true,
                          horizontalTitleGap: 0,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),

            SizedBox(
              height:
                  (!widget.takeAway &&
                      widget.storeId == null &&
                      Get.find<SplashController>().configModel!.dmTipsStatus ==
                          1)
                  ? Dimensions.paddingSizeSmall
                  : 0,
            ),
          ],
        );
      },
    );
  }
}

class _CustomTipField extends StatelessWidget {
  final CheckoutController checkoutController;
  final ValueChanged<double> onChanged;

  const _CustomTipField({
    required this.checkoutController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    final bool hasCustomTip =
        checkoutController.selectedTips == -1 &&
        checkoutController.tipController.text.trim().isNotEmpty &&
        checkoutController.tipController.text.trim() != 'not_now';

    if (isDesktop) {
      return Container(
        width: 140,
        height: 46,
        margin: const EdgeInsets.only(
          right: Dimensions.paddingSizeSmall,
          top: Dimensions.paddingSizeExtraSmall,
        ),
        child: TextField(
          controller: checkoutController.tipController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'enter_amount'.tr,
            suffixText:
                Get.find<SplashController>().configModel?.currencySymbol ?? '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          onChanged: (String value) {
            onChanged(double.tryParse(value.trim()) ?? 0);
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        right: Dimensions.paddingSizeSmall,
        top: Dimensions.paddingSizeExtraSmall,
        bottom: 0,
      ),
      child: SizedBox(
        width: 56,
        height: 42,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(
              color: hasCustomTip
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 0.5,
                blurRadius: 0.5,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              TextField(
                controller: checkoutController.tipController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                expands: true,
                minLines: null,
                maxLines: null,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: '0',
                ),
                onTap: () {
                  if (checkoutController.selectedTips != -1) {
                    checkoutController.updateTips(-1);
                  }
                },
                onChanged: (String value) {
                  onChanged(double.tryParse(value.trim()) ?? 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
