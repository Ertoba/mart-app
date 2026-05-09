import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_bottom_sheet.dart';

class PaymentSection extends StatelessWidget {
  final int? storeId;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final CheckoutController checkoutController;
  final bool isOfflinePaymentActive;
  const PaymentSection({
    super.key,
    this.storeId,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.checkoutController,
    required this.isOfflinePaymentActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              storeId != null
                  ? 'payment_method'.tr
                  : 'choose_payment_method'.tr,
              style: robotoMedium,
            ),

            storeId == null && !ResponsiveHelper.isDesktop(context)
                ? InkWell(
                    onTap: () {
                      if (isCashOnDeliveryActive ||
                          isDigitalPaymentActive ||
                          isWalletActive ||
                          isOfflinePaymentActive) {
                        Get.bottomSheet(
                          PaymentMethodBottomSheet(
                            isCashOnDeliveryActive: isCashOnDeliveryActive,
                            isDigitalPaymentActive: isDigitalPaymentActive,
                            totalPrice: total,
                            isOfflinePaymentActive: isOfflinePaymentActive,
                          ),
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                        );
                      } else {
                        showCustomSnackBar('no_payment_method_found'.tr);
                      }
                    },
                    child: Image.asset(
                      Images.paymentSelect,
                      height: 24,
                      width: 24,
                    ),
                  )
                : const SizedBox(),
          ],
        ),

        !ResponsiveHelper.isDesktop(context)
            ? const Divider()
            : const SizedBox(height: Dimensions.paddingSizeSmall),
        SizedBox(
          height: !ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeSmall
              : 0,
        ),

        Container(
          decoration: ResponsiveHelper.isDesktop(context)
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                )
              : const BoxDecoration(),
          padding: ResponsiveHelper.isDesktop(context)
              ? const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                  horizontal: Dimensions.radiusDefault,
                )
              : EdgeInsets.zero,
          child: storeId != null
              ? checkoutController.paymentMethodIndex == 0
                    ? Row(
                        children: [
                          Image.asset(
                            Images.cash,
                            width: 20,
                            height: 20,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: Text(
                              'cash_on_delivery'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ),

                          Text(
                            PriceConverter.convertPrice(total),
                            textDirection: TextDirection.ltr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox()
              : InkWell(
                  onTap: () {
                    if (ResponsiveHelper.isDesktop(context) &&
                        checkoutController.paymentMethodIndex == -1) {
                      if (isCashOnDeliveryActive ||
                          isDigitalPaymentActive ||
                          isWalletActive ||
                          isOfflinePaymentActive) {
                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            child: PaymentMethodBottomSheet(
                              isCashOnDeliveryActive: isCashOnDeliveryActive,
                              isDigitalPaymentActive: isDigitalPaymentActive,
                              totalPrice: total,
                              isOfflinePaymentActive: isOfflinePaymentActive,
                            ),
                          ),
                        );
                      } else {
                        showCustomSnackBar('no_payment_method_found'.tr);
                      }
                    }
                  },
                  child: Row(
                    children: [
                      checkoutController.paymentMethodIndex != -1
                          ? _SelectedPaymentIcon(
                              paymentMethodIndex:
                                  checkoutController.paymentMethodIndex,
                            )
                          : Icon(
                              !ResponsiveHelper.isDesktop(context)
                                  ? Icons.wallet_outlined
                                  : Icons.add_circle_outline_sharp,
                              size: 18,
                              color: !ResponsiveHelper.isDesktop(context)
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).primaryColor,
                            ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Builder(
                                builder: (context) {
                                  //print('=======pay: ${checkoutController.paymentMethodIndex}==== ${checkoutController.isPartialPay}');
                                  return Text(
                                    checkoutController.paymentMethodIndex == 0
                                        ? '${'cash_on_delivery'.tr} ${checkoutController.isPartialPay ? '(${'partial'.tr})' : ''}'
                                        : checkoutController
                                                      .paymentMethodIndex ==
                                                  1 &&
                                              !checkoutController.isPartialPay
                                        ? 'wallet_payment'.tr
                                        : checkoutController
                                                  .paymentMethodIndex ==
                                              2
                                        ? '${'digital_payment'.tr}${checkoutController.isPartialPay ? ' (${'partial'.tr})' : ''}'
                                        : checkoutController
                                                  .paymentMethodIndex ==
                                              3
                                        ? '${'offline_payment'.tr}(${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName}${checkoutController.isPartialPay ? ' - ${'partial'.tr}' : ''})'
                                        : !ResponsiveHelper.isDesktop(context)
                                        ? 'select_payment_method'.tr
                                        : 'add_payment_method'.tr,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color:
                                          !ResponsiveHelper.isDesktop(context)
                                          ? Theme.of(context).disabledColor
                                          : checkoutController
                                                    .paymentMethodIndex ==
                                                -1
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).disabledColor,
                                    ),
                                  );
                                },
                              ),
                            ),

                            checkoutController.paymentMethodIndex == -1 &&
                                    !ResponsiveHelper.isDesktop(context)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    child: Icon(
                                      Icons.warning_rounded,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      checkoutController.paymentMethodIndex != -1
                          ? PriceConverter.convertAnimationPrice(
                              checkoutController.viewTotalPrice,
                              textStyle: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : const SizedBox(),
                      SizedBox(
                        width: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.paddingSizeSmall
                            : 0,
                      ),

                      storeId == null && ResponsiveHelper.isDesktop(context)
                          ? InkWell(
                              onTap: () {
                                if (isCashOnDeliveryActive ||
                                    isDigitalPaymentActive ||
                                    isWalletActive ||
                                    isOfflinePaymentActive) {
                                  Get.dialog(
                                    Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: PaymentMethodBottomSheet(
                                        isCashOnDeliveryActive:
                                            isCashOnDeliveryActive,
                                        isDigitalPaymentActive:
                                            isDigitalPaymentActive,
                                        totalPrice: total,
                                        isOfflinePaymentActive:
                                            isOfflinePaymentActive,
                                      ),
                                    ),
                                  );
                                } else {
                                  showCustomSnackBar(
                                    'no_payment_method_found'.tr,
                                  );
                                }
                              },
                              child: Image.asset(
                                Images.paymentSelect,
                                height: 24,
                                width: 24,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _SelectedPaymentIcon extends StatelessWidget {
  final int paymentMethodIndex;

  const _SelectedPaymentIcon({required this.paymentMethodIndex});

  @override
  Widget build(BuildContext context) {
    if (paymentMethodIndex == 2) {
      return const _VisaMastercardIcon();
    }

    return Image.asset(
      paymentMethodIndex == 0
          ? Images.cash
          : paymentMethodIndex == 1
          ? Images.wallet
          : Images.cash,
      width: 20,
      height: 20,
      color: Theme.of(context).textTheme.bodyMedium!.color,
    );
  }
}

class _VisaMastercardIcon extends StatelessWidget {
  const _VisaMastercardIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 3,
            child: Container(
              width: 30,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).disabledColor.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'VISA',
                style: robotoBlack.copyWith(
                  color: const Color(0xFF1A4DB3),
                  fontSize: 7,
                ),
              ),
            ),
          ),
          Positioned(
            left: 19,
            top: 3,
            child: Container(
              width: 30,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).disabledColor.withValues(alpha: 0.25),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 6,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEB001B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF79E1B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Text(
                    'MC',
                    style: robotoBlack.copyWith(
                      color: Colors.white,
                      fontSize: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
