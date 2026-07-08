import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/checkout/domain/models/payment_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/payment/domain/models/keepz_payment_option.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/payment/widgets/offline_payment_button.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final double totalPrice;
  final PaymentModel? paymentModel;
  final bool fromHome;
  const PaymentMethodBottomSheet({
    super.key,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.totalPrice,
    required this.isOfflinePaymentActive,
    this.paymentModel,
    this.fromHome = false,
  });

  @override
  State<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  final JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    CheckoutController checkoutController = Get.find<CheckoutController>();

    if (widget.paymentModel != null) {
      checkoutController.getOfflineMethodList();
      checkoutController.setPaymentMethod(-1, isUpdate: false);
    }

    configurePartialPayment();
  }

  void configurePartialPayment() {
    if (!AuthHelper.isGuestLoggedIn()) {
      bool partialPaymentStatus =
          Get.find<SplashController>().configModel?.partialPaymentStatus ??
          false;

      if (Get.find<CheckoutController>().isPartialPay) {
        notHideWallet = false;
        if (Get.find<SplashController>().configModel!.partialPaymentMethod! ==
            'cod') {
          notHideCod = true;
          notHideDigital = false;
        } else if (Get.find<SplashController>()
                .configModel!
                .partialPaymentMethod! ==
            'digital_payment') {
          notHideCod = false;
          notHideDigital = true;
        } else if (Get.find<SplashController>()
                .configModel!
                .partialPaymentMethod! ==
            'both') {
          notHideCod = true;
          notHideDigital = true;
        }
      } else {
        if (!partialPaymentStatus) {
          double walletBalance =
              Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
          notHideWallet = walletBalance >= widget.totalPrice;
        } else {
          notHideWallet = true;
        }
        notHideCod = true;
        notHideDigital = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showOfflinePay = widget.paymentModel != null
        ? widget.paymentModel?.partiallyPaidAmount == 0
        : true;
    return SizedBox(
      width: 550,
      child: GetBuilder<CheckoutController>(
        builder: (checkoutController) {
          bool disablePayments =
              checkoutController.paymentMethodIndex == 1 &&
              !checkoutController.isPartialPay;
          bool showDigitalMethods =
              widget.isDigitalPaymentActive &&
              notHideDigital &&
              Get.find<SplashController>()
                  .configModel!
                  .activePaymentMethodList!
                  .isNotEmpty;
          bool showOfflineMethods =
              widget.isOfflinePaymentActive &&
              showOfflinePay &&
              !Get.find<CheckoutController>().isPartialPay;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(Dimensions.radiusLarge),
                bottom: Radius.circular(
                  ResponsiveHelper.isDesktop(context)
                      ? Dimensions.radiusLarge
                      : 0,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveHelper.isDesktop(context)
                    ? Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(Icons.clear),
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 5,
                          width: 40,
                          margin: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).disabledColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  'choose_payment_method'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'total_bill'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),

                        Text(
                          PriceConverter.convertPrice(widget.totalPrice),
                          style: robotoMedium.copyWith(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        walletView(checkoutController),

                        showDigitalMethods
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(context).disabledColor,
                                    width: 0.2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall,
                                      ),
                                      child: Text(
                                        'pay_via_online'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: disablePayments
                                              ? Theme.of(context).disabledColor
                                              : Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge!.color,
                                        ),
                                      ),
                                    ),

                                    ListView.builder(
                                      itemCount: Get.find<SplashController>()
                                          .configModel!
                                          .activePaymentMethodList!
                                          .length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final activePaymentMethod =
                                            Get.find<SplashController>()
                                                .configModel!
                                                .activePaymentMethodList![index];
                                        final bool isKeepz =
                                            activePaymentMethod.getWay ==
                                            'keepz';

                                        if (isKeepz) {
                                          return Column(
                                            children: List<Widget>.generate(
                                              KeepzPaymentOption.values.length,
                                              (int optionIndex) {
                                                final KeepzPaymentOption
                                                option = KeepzPaymentOption
                                                    .values[optionIndex];
                                                final bool isLast =
                                                    optionIndex ==
                                                        KeepzPaymentOption
                                                                .values
                                                                .length -
                                                            1 &&
                                                    index ==
                                                        Get.find<
                                                                  SplashController
                                                                >()
                                                                .configModel!
                                                                .activePaymentMethodList!
                                                                .length -
                                                            1;
                                                final bool isSelected =
                                                    checkoutController
                                                            .paymentMethodIndex ==
                                                        2 &&
                                                    checkoutController
                                                            .digitalPaymentName ==
                                                        'keepz' &&
                                                    checkoutController
                                                            .keepzPaymentOptionKey ==
                                                        option.key;

                                                return paymentButtonView(
                                                  padding: EdgeInsets.only(
                                                    bottom: isLast
                                                        ? 0
                                                        : Dimensions
                                                              .paddingSizeSmall,
                                                  ),
                                                  disablePayments:
                                                      disablePayments,
                                                  onTap: disablePayments
                                                      ? null
                                                      : () {
                                                          checkoutController
                                                              .setPaymentMethod(
                                                                2,
                                                                isUpdate: false,
                                                              );
                                                          checkoutController
                                                              .changeKeepzPaymentOption(
                                                                option,
                                                              );
                                                        },
                                                  title: option.title,
                                                  isSelected: isSelected,
                                                  assetImage: option.iconAsset,
                                                );
                                              },
                                            ),
                                          );
                                        }

                                        bool isSelected =
                                            checkoutController
                                                    .paymentMethodIndex ==
                                                2 &&
                                            activePaymentMethod.getWay! ==
                                                checkoutController
                                                    .digitalPaymentName;

                                        return paymentButtonView(
                                          padding: EdgeInsets.only(
                                            bottom:
                                                index ==
                                                    Get.find<SplashController>()
                                                            .configModel!
                                                            .activePaymentMethodList!
                                                            .length -
                                                        1
                                                ? 0
                                                : Dimensions.paddingSizeSmall,
                                          ),
                                          disablePayments: disablePayments,
                                          onTap: disablePayments
                                              ? null
                                              : () {
                                                  checkoutController
                                                      .setPaymentMethod(2);
                                                  checkoutController
                                                      .changeDigitalPaymentName(
                                                        activePaymentMethod
                                                            .getWay!,
                                                      );
                                                },
                                          title:
                                              activePaymentMethod.getWayTitle!,
                                          isSelected: isSelected,
                                          image: activePaymentMethod
                                              .getWayImageFullUrl,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        showOfflineMethods
                            ? OfflinePaymentButton(
                                isSelected:
                                    checkoutController.paymentMethodIndex == 3,
                                offlineMethodList:
                                    checkoutController.offlineMethodList,
                                isOfflinePaymentActive:
                                    widget.isOfflinePaymentActive,
                                onTap: disablePayments
                                    ? null
                                    : () {
                                        checkoutController.setPaymentMethod(3);
                                      },
                                checkoutController: checkoutController,
                                tooltipController: tooltipController,
                                disablePayment: disablePayments,
                                forParcel:
                                    widget.paymentModel?.orderType == 'parcel',
                              )
                            : const SizedBox(),

                        widget.isCashOnDeliveryActive && notHideCod
                            ? paymentButtonView(
                                padding: EdgeInsets.only(
                                  top: showDigitalMethods || showOfflineMethods
                                      ? Dimensions.paddingSizeDefault
                                      : 0,
                                  bottom: Dimensions.paddingSizeDefault,
                                ),
                                title: 'cash_on_delivery'.tr,
                                isSelected:
                                    checkoutController.paymentMethodIndex == 0,
                                disablePayments: disablePayments,
                                onTap: disablePayments
                                    ? null
                                    : () {
                                        checkoutController.setPaymentMethod(0);
                                      },
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    child: GetBuilder<OrderController>(
                      builder: (orderController) {
                        return CustomButton(
                          buttonText: widget.paymentModel == null
                              ? 'select'.tr
                              : 'proceed'.tr,
                          isLoading: widget.paymentModel != null
                              ? orderController.isLoading
                              : false,
                          onPressed: () {
                            if (widget.paymentModel != null) {
                              if (checkoutController.paymentMethodIndex == 0) {
                                if ((((widget.paymentModel?.maxCodOrderAmount !=
                                                    null &&
                                                widget
                                                        .paymentModel!
                                                        .orderAmount! <
                                                    widget
                                                        .paymentModel!
                                                        .maxCodOrderAmount!) ||
                                            widget
                                                    .paymentModel!
                                                    .maxCodOrderAmount ==
                                                null ||
                                            widget
                                                    .paymentModel!
                                                    .maxCodOrderAmount ==
                                                0) &&
                                        widget.paymentModel!.orderType !=
                                            'parcel') ||
                                    widget.paymentModel!.orderType ==
                                        'parcel') {
                                  Get.find<CheckoutController>()
                                      .paymentAfterDigitalCancel(
                                        widget.paymentModel!,
                                        widget.fromHome,
                                      );
                                } else {
                                  showCustomSnackBar(
                                    '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(orderController.paymentModel!.maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}',
                                    getXSnackBar: true,
                                  );
                                  return;
                                }
                              } else {
                                Get.find<CheckoutController>()
                                    .paymentAfterDigitalCancel(
                                      widget.paymentModel!,
                                      widget.fromHome,
                                    );
                              }
                            } else {
                              Get.back();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget paymentButtonView({
    required String title,
    String? image,
    String? assetImage,
    required bool isSelected,
    required Function? onTap,
    bool disablePayments = false,
    bool isDigitalPayment = false,
    required EdgeInsetsGeometry padding,
  }) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          decoration: image != null || assetImage != null
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(
                    color: isSelected && isDigitalPayment
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                        : Theme.of(
                            context,
                          ).disabledColor.withValues(alpha: 0.2),
                  ),
                ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(
            children: [
              if (assetImage != null)
                SizedBox(
                  width: 40,
                  child: Opacity(
                    opacity: disablePayments ? 0.35 : 1,
                    child: Image.asset(
                      assetImage,
                      height: 30,
                      width: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else if (image != null)
                SizedBox(
                  width: 40,
                  child: CustomImage(
                    height: 18,
                    fit: BoxFit.contain,
                    image: image,
                    color: disablePayments
                        ? Theme.of(context).disabledColor
                        : null,
                  ),
                )
              else
                const SizedBox(),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Text(
                  title,
                  style: isDigitalPayment
                      ? robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: disablePayments
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).textTheme.bodyLarge!.color,
                        )
                      : robotoSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: disablePayments
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                ),
              ),

              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 24,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget walletView(CheckoutController checkoutController) {
    double walletBalance =
        Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
    double balance = 0;
    if (walletBalance <= 0 ||
        (widget.paymentModel != null && walletBalance < widget.totalPrice)) {
      return const SizedBox();
    }
    if (walletBalance > widget.totalPrice &&
        checkoutController.paymentMethodIndex == 1) {
      balance = walletBalance - widget.totalPrice;
    }
    bool isWalletSelected =
        checkoutController.paymentMethodIndex == 1 ||
        checkoutController.isPartialPay;

    return Get.find<SplashController>().configModel!.customerWalletStatus ==
                1 &&
            Get.find<ProfileController>().userInfoModel != null &&
            (checkoutController.distance != -1) &&
            Get.find<ProfileController>().userInfoModel!.walletBalance! > 0 &&
            (notHideWallet || checkoutController.isPartialPay)
        ? Column(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                margin: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                    color: Theme.of(context).disabledColor,
                    width: 0.3,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWalletSelected
                              ? 'wallet_remaining_balance'.tr
                              : 'wallet_balance'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        Row(
                          children: [
                            Text(
                              PriceConverter.convertPrice(
                                isWalletSelected ? balance : walletBalance,
                              ),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraLarge,
                              ),
                            ),

                            Text(
                              isWalletSelected ? ' (${'applied'.tr})' : '',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    CustomInkWell(
                      onTap: () {
                        if (isWalletSelected) {
                          checkoutController.setPaymentMethod(-1);
                          if (checkoutController.isPartialPay) {
                            checkoutController.changePartialPayment();
                          }
                        } else {
                          if (checkoutController.isPartialPay) {
                            checkoutController.changePartialPayment();
                          }
                          checkoutController.setPaymentMethod(1);
                          if (walletBalance < widget.totalPrice) {
                            checkoutController.changePartialPayment();
                          }
                        }
                        configurePartialPayment();
                      },
                      radius: 5,
                      child: isWalletSelected
                          ? const Icon(Icons.clear, color: Colors.red)
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 20,
                              ),
                              child: Text(
                                'apply'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              if (isWalletSelected && !checkoutController.isPartialPay)
                Container(
                  margin: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'paid_by_wallet'.tr,
                        style: robotoBold.copyWith(fontSize: 14),
                      ),
                      Text(
                        PriceConverter.convertPrice(widget.totalPrice),
                        style: robotoMedium.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),

              if (isWalletSelected && checkoutController.isPartialPay)
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).disabledColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'paid_by_wallet'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                PriceConverter.convertPrice(walletBalance),
                                style: robotoMedium.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'remaining_bill'.tr,
                                style: robotoMedium.copyWith(fontSize: 14),
                              ),
                              Text(
                                PriceConverter.convertPrice(
                                  widget.totalPrice - walletBalance,
                                ),
                                style: robotoBold.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (checkoutController.paymentMethodIndex == 1)
                      Text(
                        '* ${'please_select_a_option_to_pay_remain_billing_amount'.tr}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFFE74B4B),
                        ),
                      ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
            ],
          )
        : const SizedBox();
  }
}
