import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';

class NoDataScreen extends StatelessWidget {
  final bool isCart;
  final bool showFooter;
  final String? text;
  final bool fromAddress;
  final bool isNotScrollable;
  final bool? fromInterestPage;
  const NoDataScreen({
    super.key,
    required this.text,
    this.isCart = false,
    this.showFooter = false,
    this.fromAddress = false,
    this.isNotScrollable = false,
    this.fromInterestPage = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCart) {
      return isNotScrollable
          ? const _EmptyCartView()
          : SingleChildScrollView(
              child: FooterView(
                visibility: showFooter,
                child: const _EmptyCartView(),
              ),
            );
    }

    return isNotScrollable
        ? _NoDataView(
            fromAddress: fromAddress,
            isCart: isCart,
            text: text,
            fromInterestPage: fromInterestPage!,
          )
        : SingleChildScrollView(
            child: FooterView(
              visibility: showFooter,
              child: _NoDataView(
                fromAddress: fromAddress,
                isCart: isCart,
                text: text,
                fromInterestPage: fromInterestPage!,
              ),
            ),
          );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeLarge,
      ),
      child: Center(
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 190,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(96),
                      ),
                    ),
                    Image.asset(
                      Images.emptyCart,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      right: 70,
                      top: 74,
                      child: Icon(
                        Icons.favorite_rounded,
                        color: primaryColor.withValues(alpha: 0.70),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: robotoBold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize: Dimensions.fontSizeOverLarge,
                    height: 1.25,
                  ),
                  children: [
                    const TextSpan(text: 'თქვენი კალათა '),
                    TextSpan(
                      text: 'ცარიელია',
                      style: robotoBold.copyWith(color: primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'და დაამატე ნივთები, რომლებიც მოგეწონება მაღაზიებიდან',
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: _EmptyCartFeature(
                        icon: Icons.local_offer_outlined,
                        label: 'საუკეთესო ფასები',
                      ),
                    ),
                    SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: _EmptyCartFeature(
                        icon: Icons.verified_user_outlined,
                        label: 'უსაფრთხო გადახდა',
                      ),
                    ),
                    SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: _EmptyCartFeature(
                        icon: Icons.schedule_rounded,
                        label: 'სწრაფი მიწოდება',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomButton(
                width: 320,
                buttonText: 'დაიწყე შოპინგი',
                icon: Icons.shopping_bag_outlined,
                onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCartFeature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyCartFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoDataView extends StatelessWidget {
  const _NoDataView({
    required this.fromAddress,
    required this.isCart,
    required this.text,
    required this.fromInterestPage,
  });

  final bool fromAddress;
  final bool isCart;
  final String? text;
  final bool fromInterestPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (fromInterestPage) ...[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
            ),
            child: Text(
              'choose_your_interests'.tr,
              style: robotoMedium.copyWith(fontSize: 22),
            ),
          ),
          const SizedBox(height: 100),
        ],

        Center(
          child: Image.asset(
            fromAddress
                ? Images.address
                : isCart
                ? Images.emptyCart
                : Images.noDataFound,
            width: MediaQuery.of(context).size.height * 0.15,
            height: MediaQuery.of(context).size.height * 0.15,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

        Text(
          isCart ? 'cart_is_empty'.tr : text!,
          style: robotoMedium.copyWith(
            fontSize: MediaQuery.of(context).size.height * 0.0175,
            color: fromAddress
                ? Theme.of(context).textTheme.bodyMedium!.color
                : Theme.of(context).disabledColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

        fromAddress
            ? Text(
                'please_add_your_address_for_your_better_experience'.tr,
                style: robotoMedium.copyWith(
                  fontSize: MediaQuery.of(context).size.height * 0.0175,
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              )
            : const SizedBox(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        fromAddress
            ? InkWell(
                onTap: () => Get.toNamed(
                  RouteHelper.getAddAddressRoute(false, false, 0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline_sharp,
                        size: 18.0,
                        color: Theme.of(context).cardColor,
                      ),
                      Text(
                        'add_address'.tr,
                        style: robotoMedium.copyWith(
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),

        fromInterestPage
            ? CustomButton(
                buttonText: 'continue'.tr,
                width: 300,
                onPressed: () {
                  if (ResponsiveHelper.isDesktop(Get.context)) {
                    Get.offAllNamed(RouteHelper.getInitialRoute());
                  } else {
                    Get.back();
                  }
                },
              )
            : const SizedBox(),
      ],
    );
  }
}
