import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  MenuDrawerState createState() => MenuDrawerState();
}

class MenuDrawerState extends State<MenuDrawer>
    with SingleTickerProviderStateMixin {
  final List<Menu> _menuList = [
    Menu(
      icon: Images.profile,
      materialIcon: Icons.person_outline,
      title: 'profile'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(RouteHelper.getProfileRoute());
      },
    ),
    Menu(
      icon: Images.orders,
      materialIcon: Icons.receipt_long_outlined,
      title: 'my_orders'.tr,
      onTap: () {
        Get.back();
        Get.offAllNamed(RouteHelper.getOrderRoute());
      },
    ),
    Menu(
      icon: Images.location,
      materialIcon: Icons.map_outlined,
      title: 'my_address'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(RouteHelper.getAddressRoute());
      },
    ),
    Menu(
      icon: Images.language,
      materialIcon: Icons.translate,
      title: 'language'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(RouteHelper.getLanguageRoute('menu'));
      },
    ),
    Menu(
      icon: Images.coupon,
      materialIcon: Icons.confirmation_number_outlined,
      title: 'coupon'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(RouteHelper.getCouponRoute());
      },
    ),
    Menu(
      icon: Images.support,
      materialIcon: Icons.support_agent_outlined,
      title: 'help_support'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(RouteHelper.getSupportRoute());
      },
    ),
    Menu(
      icon: Images.chat,
      materialIcon: Icons.chat_bubble_outline,
      title: 'live_chat'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(RouteHelper.getConversationRoute());
      },
    ),
  ];

  static const _initialDelayTime = Duration(milliseconds: 200);
  static const _itemSlideTime = Duration(milliseconds: 250);
  static const _staggerTime = Duration(milliseconds: 50);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);
  final _animationDuration =
      _initialDelayTime + (_staggerTime * 7) + _buttonDelayTime + _buttonTime;

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];

  @override
  void initState() {
    super.initState();

    if (Get.find<SplashController>().configModel!.refundPolicyStatus == 1) {
      _menuList.add(
        Menu(
          icon: Images.refund,
          materialIcon: Icons.assignment_return_outlined,
          title: 'refund_policy'.tr,
          onTap: () {
            Get.back();
            Get.toNamed(RouteHelper.refundPolicy);
          },
        ),
      );
    }
    if (Get.find<SplashController>().configModel!.cancellationPolicyStatus ==
        1) {
      _menuList.add(
        Menu(
          icon: Images.cancellation,
          materialIcon: Icons.cancel_presentation_outlined,
          title: 'cancellation_policy'.tr,
          onTap: () {
            Get.back();
            Get.toNamed(RouteHelper.cancellationPolicy);
          },
        ),
      );
    }
    if (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1) {
      _menuList.add(
        Menu(
          icon: Images.shippingPolicy,
          materialIcon: Icons.local_shipping_outlined,
          title: 'shipping_policy'.tr,
          onTap: () {
            Get.back();
            Get.toNamed(RouteHelper.shippingPolicy);
          },
        ),
      );
    }

    if (Get.find<SplashController>().configModel!.customerWalletStatus == 1) {
      _menuList.add(
        Menu(
          icon: Images.wallet,
          materialIcon: Icons.account_balance_wallet_outlined,
          title: 'wallet'.tr,
          onTap: () {
            if (Get.currentRoute.contains('wallet')) {
              Get.back();
            }
            Get.back();
            Get.toNamed(RouteHelper.getWalletRoute());
          },
        ),
      );
    }

    if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1) {
      _menuList.add(
        Menu(
          icon: Images.loyal,
          materialIcon: Icons.stars_outlined,
          title: 'loyalty_points'.tr,
          onTap: () {
            Get.back();
            Get.toNamed(RouteHelper.getLoyaltyRoute());
          },
        ),
      );
    }
    if (Get.find<SplashController>().configModel!.refEarningStatus == 1) {
      _menuList.add(
        Menu(
          icon: Images.referCode,
          materialIcon: Icons.person_add_alt_1_outlined,
          title: 'refer_and_earn'.tr,
          onTap: () {
            Get.back();
            Get.toNamed(RouteHelper.getReferAndEarnRoute());
          },
        ),
      );
    }
    if (Get.find<SplashController>().configModel!.toggleDmRegistration!) {
      _menuList.add(
        Menu(
          icon: Images.deliveryManJoin,
          materialIcon: Icons.two_wheeler,
          title: 'join_as_a_delivery_man'.tr,
          onTap: () {
            Get.back();
            Get.toNamed(RouteHelper.getDeliverymanRegistrationRoute());
          },
        ),
      );
    }
    if (Get.find<SplashController>().configModel!.toggleStoreRegistration!) {
      _menuList.add(
        Menu(
          icon: Images.restaurantJoin,
          materialIcon: Icons.storefront,
          title: ModuleHelper.isBeerModule
              ? 'join_as_a_bar'.tr
              : Get.find<SplashController>()
                    .configModel!
                    .moduleConfig!
                    .module!
                    .showRestaurantText!
              ? 'join_as_a_restaurant'.tr
              : 'join_as_a_store'.tr,
          onTap: () {
            Get.back();
            Get.toNamed(RouteHelper.getRestaurantRegistrationRoute());
          },
        ),
      );
    }
    _menuList.add(
      Menu(
        icon: Images.logOut,
        materialIcon: AuthHelper.isLoggedIn()
            ? Icons.power_settings_new
            : Icons.login,
        title: AuthHelper.isLoggedIn() ? 'logout'.tr : 'sign_in'.tr,
        onTap: () {
          Get.back();
          if (AuthHelper.isLoggedIn()) {
            Get.dialog(
              ConfirmationDialog(
                icon: Images.support,
                description: 'are_you_sure_to_logout'.tr,
                isLogOut: true,
                onYesPressed: () async {
                  Get.find<AuthController>().resetOtpView();
                  Get.find<ProfileController>().clearUserInfo();
                  await Get.find<AuthController>().clearSharedData();
                  Get.find<CartController>().clearCartList();
                  Get.find<AuthController>().socialLogout();
                  Get.find<FavouriteController>().removeFavourite();
                  if (ResponsiveHelper.isDesktop(Get.context)) {
                    Get.offAllNamed(RouteHelper.getInitialRoute());
                  } else {
                    Get.offAllNamed(
                      RouteHelper.getSignInRoute(RouteHelper.splash),
                    );
                  }
                },
              ),
              useSafeArea: false,
            );
          } else {
            Get.find<FavouriteController>().removeFavourite();
            if (ResponsiveHelper.isDesktop(context)) {
              Get.dialog(
                const Center(
                  child: AuthDialogWidget(
                    exitFromApp: false,
                    backFromThis: false,
                  ),
                ),
                barrierDismissible: false,
              );
            } else {
              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
            }
          }
        },
      ),
    );

    _createAnimationIntervals();

    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuList.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? _buildContent()
        : const SizedBox();
  }

  Widget _buildContent() {
    return Align(
      alignment: Get.find<LocalizationController>().isLtr
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Container(
        width: 300,
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeLarge,
                horizontal: 25,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('menu'.tr, style: robotoBold.copyWith(fontSize: 20)),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _menuList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _staggeredController,
                    builder: (context, child) {
                      final animationPercent = Curves.easeOut.transform(
                        _itemSlideIntervals[index].transform(
                          _staggeredController.value,
                        ),
                      );
                      final opacity = animationPercent;
                      final slideDistance = (1.0 - animationPercent) * 150;

                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(slideDistance, 0),
                          child: child,
                        ),
                      );
                    },
                    child: OnHover(
                      isItem: true,
                      fromMenu: true,
                      child: InkWell(
                        onTap: _menuList[index].onTap as void Function()?,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 55,
                                width: 55,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  color: index != _menuList.length - 1
                                      ? Theme.of(context).primaryColor
                                      : AuthHelper.isLoggedIn()
                                      ? Theme.of(context).colorScheme.error
                                      : Colors.green,
                                ),
                                child: _menuList[index].materialIcon != null
                                    ? Icon(
                                        _menuList[index].materialIcon,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                    : Image.asset(
                                        _menuList[index].icon,
                                        color: Colors.white,
                                        height: 30,
                                        width: 30,
                                      ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),

                              Expanded(
                                child: Text(
                                  _menuList[index].title,
                                  style: robotoMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Menu {
  String icon;
  IconData? materialIcon;
  String title;
  Function onTap;

  Menu({
    required this.icon,
    this.materialIcon,
    required this.title,
    required this.onTap,
  });
}
