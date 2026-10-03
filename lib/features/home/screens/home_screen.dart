import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/lazy_sliver.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/brands/controllers/brands_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/home/controllers/advertisement_controller.dart';
import 'package:sixam_mart/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/reels/controllers/reels_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/home/screens/modules/food_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/grocery_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/shop_home_screen.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/reels/controllers/reels_controller.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
class HomeScreen {
  static const Set<String> _lazyModules = {
    AppConstants.food, AppConstants.grocery, AppConstants.ecommerce, AppConstants.pharmacy,
  };

  static bool isLazyModule(String? moduleType) => moduleType != null && _lazyModules.contains(moduleType);

  static void loadCriticalModuleData(String moduleType, bool reload) {
    switch(moduleType) {
      case AppConstants.food:
        Get.find<CategoryController>().getCategoryList(reload);
        Get.find<BannerController>().getBannerList(reload);
        Get.find<HomeController>().getTopOffer(notify: false);

      case AppConstants.grocery:
        Get.find<CategoryController>().getCategoryList(reload);
        Get.find<HomeController>().getTopOffer(notify: false);
        Get.find<BannerController>().getBannerList(reload);

      case AppConstants.ecommerce:
        Get.find<BannerController>().getBannerList(reload);
        Get.find<CategoryController>().getCategoryList(reload);
        Get.find<HomeController>().getTopOffer(notify: false);

      case AppConstants.pharmacy:
        Get.find<ItemController>().getCommonConditions(false);
        Get.find<CategoryController>().getCategoryList(reload);
    }
  }

  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    print('===== Home Screen Load Data =====');
    Get.find<LocationController>().syncZoneData();
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);

    final String moduleType = Get.find<SplashController>().module?.moduleType.toString() ?? '';
    final bool isStoreModule = Get.find<SplashController>().module != null
        && moduleType != AppConstants.ride
        && !Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!
        && !Get.find<SplashController>().configModel!.moduleConfig!.module!.isTaxi!;


    if(reload && !fromModule) {
      LazyRefreshNotifier.bump();
    }

    // Driven from here rather than the controller's onInit so it also re-runs when the
    // user switches module — a Happy Hour belongs to the module it was configured for.
    if(isStoreModule) {
      Get.find<HappyHourController>().getRunningHappyHour();
    }

    if(isStoreModule && isLazyModule(moduleType)) {
      // Converted module: only the above-the-fold fetches. Every other section is
      // wrapped in a LazySliver in the module screen and fetches when scrolled to.
      loadCriticalModuleData(moduleType, reload);
    }
    else if(isStoreModule) {

      if(AuthHelper.isLoggedIn() && Get.find<SplashController>().configModel!.repeatOrderOption == 1) {
        Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
      }

      Get.find<BannerController>().getBannerList(reload);
      Get.find<StoreController>().getRecommendedStoreList();
      if(Get.find<SplashController>().module!.moduleType.toString() == AppConstants.grocery) {
        Get.find<FlashSaleController>().getFlashSale(reload, false);
        Get.find<BrandsController>().getBrandList();
      }
      if(Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        Get.find<FlashSaleController>().getFlashSale(reload, false);
        Get.find<BrandsController>().getBrandList();
      }
      if(Get.find<SplashController>().module!.moduleType.toString() == AppConstants.grocery) {
        Get.find<BrandsController>().getBrandList();
      }
      Get.find<BannerController>().getPromotionalBannerList(reload);
      Get.find<ReelsController>().getReelsList(offset: 1);
      Get.find<ItemController>().getDiscountedItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<ItemController>().getPopularItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<ItemController>().getReviewedItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<CategoryController>().getCategoryList(reload);
      Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getBasicCampaignList(reload);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<StoreController>().getTopOfferStoreList(reload, false);
      Get.find<ItemController>().getRecommendedItemList(reload, 'all', false);
      Get.find<StoreController>().getStoreList(1, reload);
      Get.find<AdvertisementController>().getAdvertisementList();
      Get.find<ReelsController>().getReelsList(offset: 1);
    }
    if(AuthHelper.isLoggedIn()) {
      await Get.find<ProfileController>().getUserInfo();

      final String? moduleType = Get.find<SplashController>().module?.moduleType
          ?.toString();

      if (<String>{
        AppConstants.food,
        AppConstants.grocery,
        AppConstants.ecommerce,
        AppConstants.pharmacy,
      }.contains(moduleType)) {
        Get.find<ItemController>().getSuggestedItemList(reload);
      }

      Get.find<NotificationController>().getNotificationList(reload);
      if(Get.find<SplashController>().configModel!.repeatOrderOption == 1) {
        Get.find<OrderController>().getLastOrders(reload: reload, isHome: true);
        if(!isLazyModule(moduleType)) {
          Get.find<OrderController>().getLastOrders(reload: reload, isHome: false);
        }
      }
      if(!Get.find<SplashController>().configModel!.moduleConfig!.module!.isRide!) {
        Get.find<CouponController>().getCouponList();
      }
    }
    Get.find<SplashController>().getModules();
    if(Get.find<SplashController>().module == null && Get.find<SplashController>().configModel!.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if(AuthHelper.isLoggedIn()) {
        Get.find<AddressController>().getAddressList();
      }
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!) {
      Get.find<ParcelController>().getParcelCategoryList();

      Get.find<BannerController>().getPromotionalBannerList(reload);
    }
    if(!isLazyModule(moduleType)
        && Get.find<SplashController>().module != null
        && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy) {
      Get.find<ItemController>().getBasicMedicine(reload, false);
      Get.find<StoreController>().getFeaturedStoreList();
      Get.find<StoreController>().getVerifiedStoreList(reload: reload, notify: false);
      Get.find<ItemController>().getCommonConditions(false);
    }
  }

  static Future<void> loadTaxiApis() async {
    await Get.find<TaxiHomeController>().getTaxiBannerList(true);
    await Get.find<TaxiHomeController>().getTopRatedCarList(1, true);
    if (AuthHelper.isLoggedIn()) {
      await Get.find<AddressController>().getAddressList();
      await Get.find<TaxiHomeController>().getTaxiCouponList(true);
      await Get.find<TaxiCartController>().getCarCartList();
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool searchBgShow = false;
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // PusherHelper.initializePusher();

    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if ((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ??
              false) &&
          Get.find<SplashController>().showReferBottomSheet) {
        _showReferBottomSheet();
      }
    });

    if (!ResponsiveHelper.isWeb()) {
      Get.find<LocationController>().getZone(
        AddressHelper.getUserAddressFromSharedPref()?.latitude ?? '',
        AddressHelper.getUserAddressFromSharedPref()?.longitude ?? '',
        false,
        updateInAddress: true,
      );
    }

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility(value: false);
          Future.delayed(
            const Duration(milliseconds: 800),
            () => Get.find<HomeController>().changeFavVisibility(value: true),
          );
        }
      } else {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility(value: false);
          Future.delayed(
            const Duration(milliseconds: 800),
            () => Get.find<HomeController>().changeFavVisibility(value: true),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context)
        ? Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusExtraLarge,
                ),
              ),
              insetPadding: const EdgeInsets.all(22),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: const ReferBottomSheetWidget(),
            ),
            useSafeArea: false,
          ).then(
            (value) =>
                Get.find<SplashController>().saveReferBottomSheetStatus(false),
          )
        : showModalBottomSheet(
            isScrollControlled: true,
            useRootNavigator: true,
            context: Get.context!,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                topRight: Radius.circular(Dimensions.radiusExtraLarge),
              ),
            ),
            builder: (context) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: const ReferBottomSheetWidget(),
              );
            },
          ).then(
            (value) =>
                Get.find<SplashController>().saveReferBottomSheetStatus(false),
          );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (splashController) {
        if (splashController.moduleList != null &&
            splashController.moduleList!.length == 1) {
          splashController.switchModule(0, true);
        }
        bool showMobileModule =
            !ResponsiveHelper.isDesktop(context) &&
            splashController.module == null &&
            splashController.configModel!.module == null;
        bool isParcel =
            splashController.module != null &&
            splashController.module!.moduleType.toString() ==
                AppConstants.parcel;
        bool isPharmacy =
            splashController.module != null &&
            splashController.module!.moduleType.toString() ==
                AppConstants.pharmacy;
        bool isFood =
            splashController.module != null &&
            splashController.module!.moduleType.toString() == AppConstants.food;
        bool isShop =
            splashController.module != null &&
            splashController.module!.moduleType.toString() ==
                AppConstants.ecommerce;
        bool isGrocery =
            splashController.module != null &&
            splashController.module!.moduleType.toString() ==
                AppConstants.grocery;
        bool isTaxi =
            splashController.module != null &&
            splashController.module!.moduleType.toString() == AppConstants.taxi;

        return GetBuilder<HomeController>(
          builder: (homeController) {
            return Scaffold(
              appBar: ResponsiveHelper.isDesktop(context)
                  ? const WebMenuBar()
                  : null,
              endDrawer: const MenuDrawer(),
              endDrawerEnableOpenDragGesture: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: isParcel
                  ? const ParcelCategoryScreen()
                  : SafeArea(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          splashController.setRefreshing(true);
                          if (Get.find<SplashController>().module != null &&
                              !isTaxi) {
                            await Get.find<LocationController>().syncZoneData();
                            await Get.find<BannerController>().getBannerList(
                              true,
                            );
                            if (isGrocery) {
                              await Get.find<FlashSaleController>()
                                  .getFlashSale(true, true);
                            }
                            await Get.find<BannerController>()
                                .getPromotionalBannerList(true);
                            await Get.find<ItemController>()
                                .getDiscountedItemList(offset: '1');
                            await Get.find<CategoryController>()
                                .getCategoryList(true);
                            await Get.find<StoreController>()
                                .getPopularStoreList(true, 'all', false);
                            await Get.find<CampaignController>()
                                .getItemCampaignList(true);
                            Get.find<CampaignController>().getBasicCampaignList(
                              true,
                            );
                            await Get.find<ItemController>().getPopularItemList(
                              offset: '1',
                            );
                            await Get.find<StoreController>()
                                .getLatestStoreList(true, 'all', false);
                            await Get.find<StoreController>()
                                .getTopOfferStoreList(true, false);
                            await Get.find<ItemController>()
                                .getReviewedItemList(offset: '1');
                            await Get.find<StoreController>().getStoreList(
                              1,
                              true,
                            );
                            Get.find<AdvertisementController>()
                                .getAdvertisementList();
                            Get.find<ReelsController>().getReelsList(offset: 1);
                            if (AuthHelper.isLoggedIn()) {
                              await Get.find<ProfileController>().getUserInfo();
                              await Get.find<NotificationController>()
                                  .getNotificationList(true);
                              Get.find<CouponController>().getCouponList();
                            }
                            if (isPharmacy) {
                              Get.find<ItemController>().getBasicMedicine(
                                true,
                                true,
                              );
                              Get.find<ItemController>().getCommonConditions(
                                true,
                              );
                            }
                            if (isShop) {
                              await Get.find<FlashSaleController>()
                                  .getFlashSale(true, true);
                              Get.find<ItemController>()
                                  .getFeaturedCategoriesItemList(true, true);
                              Get.find<BrandsController>().getBrandList();
                            }
                          } else if (isTaxi) {
                            await HomeScreen.loadTaxiApis();
                          } else {
                            await Get.find<BannerController>()
                                .getFeaturedBanner();
                            await Get.find<SplashController>().getModules();
                            if (AuthHelper.isLoggedIn()) {
                              await Get.find<AddressController>()
                                  .getAddressList();
                            }
                            await Get.find<StoreController>()
                                .getFeaturedStoreList();
                          }
                          splashController.setRefreshing(false);
                        },
                        child: ResponsiveHelper.isDesktop(context)
                            ? WebNewHomeScreen(
                                scrollController: _scrollController,
                              )
                            : CustomScrollView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  /// App Bar
                                  SliverAppBar(
                                    floating: true,
                                    elevation: 0,
                                    automaticallyImplyLeading: false,
                                    surfaceTintColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    backgroundColor:
                                        ResponsiveHelper.isDesktop(context)
                                        ? Colors.transparent
                                        : Theme.of(context).colorScheme.surface,
                                    title: Center(
                                      child: Container(
                                        width: Dimensions.webMaxWidth,
                                        height:
                                            Get.find<LocalizationController>()
                                                .isLtr
                                            ? 60
                                            : 70,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        child: Row(
                                          children: [
                                            (splashController.module != null &&
                                                    splashController
                                                            .configModel!
                                                            .module ==
                                                        null &&
                                                    splashController
                                                            .moduleList !=
                                                        null &&
                                                    splashController
                                                            .moduleList!
                                                            .length !=
                                                        1)
                                                ? InkWell(
                                                    onTap: () {
                                                      splashController
                                                          .removeModule();
                                                      Get.find<
                                                            StoreController
                                                          >()
                                                          .resetStoreData();
                                                    },
                                                    child: Image.asset(
                                                      Images.moduleIcon,
                                                      height: 25,
                                                      width: 25,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              width:
                                                  (splashController.module !=
                                                          null &&
                                                      splashController
                                                              .configModel!
                                                              .module ==
                                                          null &&
                                                      splashController
                                                              .moduleList !=
                                                          null &&
                                                      splashController
                                                              .moduleList!
                                                              .length !=
                                                          1)
                                                  ? Dimensions.paddingSizeSmall
                                                  : 0,
                                            ),

                                            Expanded(
                                              child: GetBuilder<LocationController>(
                                                builder: (locationController) {
                                                  return AddressHelper.getUserAddressFromSharedPref() !=
                                                          null
                                                      ? InkWell(
                                                          onTap: () =>
                                                              Get.find<
                                                                    LocationController
                                                                  >()
                                                                  .navigateToLocationScreen(
                                                                    'home',
                                                                  ),
                                                          child: Padding(
                                                            padding: EdgeInsets.symmetric(
                                                              vertical: Dimensions
                                                                  .paddingSizeSmall,
                                                              horizontal:
                                                                  ResponsiveHelper.isDesktop(
                                                                    context,
                                                                  )
                                                                  ? Dimensions
                                                                        .paddingSizeSmall
                                                                  : 0,
                                                            ),
                                                            child:
                                                                GetBuilder<
                                                                  LocationController
                                                                >(
                                                                  builder:
                                                                      (
                                                                        locationController,
                                                                      ) {
                                                                        return Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              AuthHelper.isLoggedIn()
                                                                                  ? AddressHelper.getAddressTypeLabel(
                                                                                      AddressHelper.getUserAddressFromSharedPref()?.addressType,
                                                                                    )
                                                                                  : 'your_location'.tr,
                                                                              style: robotoMedium.copyWith(
                                                                                color: Theme.of(
                                                                                  context,
                                                                                ).textTheme.bodyLarge!.color,
                                                                                fontSize: Dimensions.fontSizeDefault,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),

                                                                            Row(
                                                                              children: [
                                                                                Flexible(
                                                                                  child: Text(
                                                                                    AddressHelper.getUserAddressFromSharedPref()!.address!,
                                                                                    style: robotoRegular.copyWith(
                                                                                      color: Theme.of(
                                                                                        context,
                                                                                      ).disabledColor,
                                                                                      fontSize: Dimensions.fontSizeSmall,
                                                                                    ),
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),

                                                                                Icon(
                                                                                  Icons.expand_more,
                                                                                  color: Theme.of(
                                                                                    context,
                                                                                  ).disabledColor,
                                                                                  size: 18,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                ),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          hoverColor: Colors
                                                              .transparent,
                                                          onTap: () {
                                                            locationController
                                                                .navigateToLocationScreen(
                                                                  'home',
                                                                );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      Dimensions
                                                                          .paddingSizeSmall,
                                                                ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .location_solid,
                                                                  size: 16,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).primaryColor,
                                                                ),
                                                                const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeExtraSmall,
                                                                ),

                                                                CustomToolTip(
                                                                  message:
                                                                      'sharing_your_accurate_location_enhances_precision_in_search_results_and_delivery_estimates_ensures_effortless_order_delivery'
                                                                          .tr,
                                                                  preferredDirection:
                                                                      AxisDirection
                                                                          .down,
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall,
                                                                  isShowOnInit:
                                                                      true,
                                                                  child: InkWell(
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () async {
                                                                      locationController
                                                                          .navigateToLocationScreen(
                                                                            'home',
                                                                          );
                                                                    },
                                                                    child: Text(
                                                                      'select_your_location'
                                                                          .tr,
                                                                      style: robotoMedium.copyWith(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).primaryColor,
                                                                        fontSize:
                                                                            Dimensions.fontSizeExtraSmall,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                },
                                              ),
                                            ),
                                            InkWell(
                                              child: GetBuilder<NotificationController>(
                                                builder: (notificationController) {
                                                  return Stack(
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons.bell,
                                                        size: 25,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color,
                                                      ),
                                                      notificationController
                                                              .hasNotification
                                                          ? Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: Container(
                                                                height: 10,
                                                                width: 10,
                                                                decoration: BoxDecoration(
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).primaryColor,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                    width: 1,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).cardColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  );
                                                },
                                              ),
                                              onTap: () => Get.toNamed(
                                                RouteHelper.getNotificationRoute(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [const SizedBox()],
                                  ),

                                  /// Search Button
                                  !showMobileModule && !isTaxi
                                      ? SliverPersistentHeader(
                                          pinned: true,
                                          delegate: SliverDelegate(
                                            callback: (val) {},
                                            child: Center(
                                              child: Container(
                                                height: 50,
                                                width: Dimensions.webMaxWidth,
                                                color: searchBgShow
                                                    ? Get.find<
                                                                ThemeController
                                                              >()
                                                              .darkTheme
                                                          ? Theme.of(context)
                                                                .colorScheme
                                                                .surface
                                                          : Theme.of(
                                                              context,
                                                            ).cardColor
                                                    : null,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall,
                                                    ),
                                                child: isTaxi
                                                    ? Container(
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      )
                                                    : InkWell(
                                                        onTap: () => Get.toNamed(
                                                          RouteHelper.getSearchRoute(),
                                                        ),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                          margin:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 3,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(
                                                              context,
                                                            ).cardColor,
                                                            border: Border.all(
                                                              color: Theme.of(
                                                                context,
                                                              ).disabledColor,
                                                              width: 0.2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  25,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                      alpha:
                                                                          0.05,
                                                                    ),
                                                                blurRadius: 4,
                                                                spreadRadius: 1,
                                                                offset: Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .search,
                                                                size: 25,
                                                                color: Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                              ),
                                                              const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeExtraSmall,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  ModuleHelper
                                                                      .searchHintKey
                                                                      .tr,
                                                                  style: robotoRegular.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).hintColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .keyboard_voice_sharp,
                                                                size: 22,
                                                                color: Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SliverToBoxAdapter(),

                                  SliverToBoxAdapter(
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: !showMobileModule
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  isGrocery
                                                      ? const GroceryHomeScreen()
                                                      : isPharmacy
                                                      ? const PharmacyHomeScreen()
                                                      : isFood
                                                      ? const FoodHomeScreen()
                                                      : isShop
                                                      ? const ShopHomeScreen()
                                                      : isTaxi
                                                      ? const TaxiHomeScreen()
                                                      : const SizedBox(),
                                                ],
                                              )
                                            : ModuleView(
                                                splashController:
                                                    splashController,
                                              ),
                                      ),
                                    ),
                                  ),

                                  !showMobileModule && !isTaxi
                                      ? SliverPersistentHeader(
                                          key: _headerKey,
                                          pinned: true,
                                          delegate: SliverDelegate(
                                            height: 85,
                                            callback: (val) {
                                              searchBgShow = val;
                                            },
                                            child: const AllStoreFilterWidget(),
                                          ),
                                        )
                                      : const SliverToBoxAdapter(),

                                  SliverToBoxAdapter(
                                    child: !showMobileModule && !isTaxi
                                        ? Center(
                                            child: GetBuilder<StoreController>(
                                              builder: (storeController) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 0
                                                        : 100,
                                                  ),
                                                  child: PaginatedListView(
                                                    scrollController:
                                                        _scrollController,
                                                    totalSize: storeController
                                                        .storeModel
                                                        ?.totalSize,
                                                    offset: storeController
                                                        .storeModel
                                                        ?.offset,
                                                    onPaginate:
                                                        (int? offset) async =>
                                                            await storeController
                                                                .getStoreList(
                                                                  offset!,
                                                                  false,
                                                                ),
                                                    gridColumns:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 3
                                                        : 1, // Desktop has 3 columns for stores, mobile 1
                                                    itemView: ItemsView(
                                                      isStore: true,
                                                      items: null,
                                                      isFoodOrGrocery:
                                                          (isFood || isGrocery),
                                                      stores: storeController
                                                          .storeModel
                                                          ?.stores,
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            ResponsiveHelper.isDesktop(
                                                              context,
                                                            )
                                                            ? Dimensions
                                                                  .paddingSizeExtraSmall
                                                            : Dimensions
                                                                  .paddingSizeSmall,
                                                        vertical:
                                                            ResponsiveHelper.isDesktop(
                                                              context,
                                                            )
                                                            ? Dimensions
                                                                  .paddingSizeExtraSmall
                                                            : Dimensions
                                                                  .paddingSizeDefault,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                      ),
                    ),

              floatingActionButton:
                  AuthHelper.isLoggedIn() &&
                      homeController.cashBackOfferList != null &&
                      homeController.cashBackOfferList!.isNotEmpty
                  ? homeController.showFavButton
                        ? Padding(
                            padding: EdgeInsets.only(
                              bottom: 50.0,
                              right: ResponsiveHelper.isDesktop(context)
                                  ? 50
                                  : 0,
                            ),
                            child: InkWell(
                              onTap: () =>
                                  Get.dialog(const CashBackDialogWidget()),
                              child: const CashBackLogoWidget(),
                            ),
                          )
                        : null
                  : null,
            );
          },
        );
      },
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  SliverDelegate({required this.child, this.height = 50, this.callback});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    isPinned = shrinkOffset == maxExtent /*|| shrinkOffset < maxExtent*/;
    callback!(isPinned);
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}
