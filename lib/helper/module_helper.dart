import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';

class ModuleHelper {
  static ModuleModel? getModule() {
    return Get.find<SplashController>().module;
  }

  static ModuleModel? getCacheModule() {
    return Get.find<SplashController>().cacheModule;
  }

  static String proMinSpendLabel({String? moduleType, required String fallbackKey}) {
    final String? type = moduleType ?? getModule()?.moduleType ?? getCacheModule()?.moduleType;
    switch (type) {
      case AppConstants.parcel:
        return 'min_delivery_fee'.tr;
      case AppConstants.taxi:
        return 'min_rental_trip'.tr;
      case AppConstants.ride:
        return 'min_ride'.tr;
      default:
        return fallbackKey.tr;
    }
  }

  static Module getModuleConfig(String? moduleType) {
    return Get.find<SplashController>().getModuleConfig(moduleType);
  }

  static bool get showRestaurantText {
    return Get.find<SplashController>()
            .configModel
            ?.moduleConfig
            ?.module
            ?.showRestaurantText ??
        false;
  }

  static String get _moduleType {
    final ModuleModel? module = getModule() ?? getCacheModule();
    return (module?.moduleType ?? '').trim().toLowerCase();
  }

  static bool get isBeerModule {
    final ModuleModel? module = getModule() ?? getCacheModule();
    final String moduleType = (module?.moduleType ?? '').trim().toLowerCase();
    final String slug = (module?.slug ?? '').trim().toLowerCase();
    final String name = (module?.moduleName ?? '').trim().toLowerCase();

    return moduleType == 'food' &&
        (slug == 'ludi' || slug == 'beer' || name == 'ლუდი' || name == 'beer');
  }

  static bool get isPharmacyModule => _moduleType == 'pharmacy';

  static bool get isRestaurantModule =>
      _moduleType == 'food' && !isBeerModule && showRestaurantText;

  static String get storeKey {
    if (isBeerModule) {
      return 'bar';
    }
    if (isPharmacyModule) {
      return 'pharmacies';
    }
    return showRestaurantText ? 'restaurants' : 'stores';
  }

  static String get storeLabel => storeKey.tr;

  static String get storesNearYouLabel => storesNearYouKey.tr;

  static String get recentPurchasePrompt {
    if (isBeerModule) {
      return 'order_again_from_last_bar'.tr;
    }
    if (isPharmacyModule) {
      return 'order_again_from_last_pharmacy'.tr;
    }
    if (isRestaurantModule) {
      return 'order_again_from_last_restaurant'.tr;
    }
    return 'get_your_recent_purchase_from_the_shop_you_recently_ordered'.tr;
  }

  static String get itemThatYouLoveKey =>
      isBeerModule ? 'beer_that_you_love' : 'item_that_you_love';

  static String get itemThatYouLoveLabel => itemThatYouLoveKey.tr;

  static String get bestStoreNearbyLabel => bestStoreNearbyKey.tr;

  static String get recommendedStoreTitleKey {
    if (isBeerModule) {
      return 'recommended_bar';
    }
    if (isPharmacyModule) {
      return 'recommended_pharmacy';
    }
    if (isRestaurantModule) {
      return 'recommended_restaurant';
    }
    return 'recommended_store';
  }

  static String get recommendedStoreLabel => recommendedStoreTitleKey.tr;

  static String get itemKey {
    return isBeerModule ? 'beer' : 'item';
  }

  static String get itemPluralKey {
    return isBeerModule ? 'beer' : 'items';
  }

  static String get searchHintKey {
    if (isBeerModule) {
      return 'search_beer_or_bar';
    }
    if (isPharmacyModule) {
      return 'search_medicine_or_pharmacy';
    }
    return showRestaurantText
        ? 'search_food_or_restaurant'
        : 'search_item_or_store';
  }

  static String get popularItemsKey {
    return isBeerModule ? 'popular_beer' : 'most_popular_items';
  }

  static String get bestReviewedItemsKey {
    return isBeerModule ? 'top_rated' : 'best_reviewed_item';
  }

  static String get bestStoreNearbyKey {
    if (isBeerModule) {
      return 'best_bar_nearby';
    }
    if (isPharmacyModule) {
      return 'best_pharmacy_nearby';
    }
    if (isRestaurantModule) {
      return 'best_restaurant_nearby';
    }
    return 'best_store_nearby';
  }

  static String get popularStoresKey {
    if (isBeerModule) {
      return 'popular_bars';
    }
    if (isPharmacyModule) {
      return 'popular_pharmacies';
    }
    return showRestaurantText ? 'popular_restaurants' : 'popular_stores';
  }

  static String get storesNearYouKey {
    if (isBeerModule) {
      return 'bars_near_you';
    }
    if (isPharmacyModule) {
      return 'pharmacies_near_you';
    }
    return showRestaurantText ? 'restaurants_near_you' : 'stores_near_you';
  }

  static String get noStoreAvailableKey {
    if (isBeerModule) {
      return 'no_bar_available';
    }
    if (isPharmacyModule) {
      return 'no_pharmacy_available';
    }
    return showRestaurantText
        ? 'no_restaurant_available'
        : 'no_store_available';
  }

  static String get currentlyOpenedStoreKey {
    if (isBeerModule) {
      return 'currently_opened_bars';
    }
    if (isPharmacyModule) {
      return 'currently_opened_pharmacies';
    }
    return showRestaurantText
        ? 'currently_opened_restaurants'
        : 'currently_opened_stores';
  }

  static String get discountedStoreKey {
    if (isBeerModule) {
      return 'discounted_bars';
    }
    if (isPharmacyModule) {
      return 'discounted_pharmacies';
    }
    return showRestaurantText ? 'discounted_restaurants' : 'discounted_stores';
  }

  static String get recommendedStoreKey {
    if (isBeerModule) {
      return 'recommended_bars';
    }
    if (isPharmacyModule) {
      return 'recommended_pharmacies';
    }
    return showRestaurantText
        ? 'recommended_restaurants'
        : 'recommended_stores';
  }

  static String get currentlyNoRecommendedStoreAvailableKey {
    if (isBeerModule) {
      return 'currently_no_recommended_bar_available';
    }
    if (isPharmacyModule) {
      return 'currently_no_recommended_pharmacy_available';
    }
    return showRestaurantText
        ? 'currently_no_recommended_restaurant_available'
        : 'currently_no_recommended_store_available';
  }

  static String get featuredStoreKey =>
      isPharmacyModule ? 'featured_pharmacies' : 'featured_store';

  static String get highlightDescriptionKey {
    if (isBeerModule) {
      return 'see_our_most_popular_bars_and_beer';
    }
    if (isPharmacyModule) {
      return 'see_our_most_popular_pharmacies_and_items';
    }
    if (isRestaurantModule) {
      return 'see_our_most_popular_restaurants_and_food';
    }
    return 'see_our_most_popular_store_and_item';
  }
}
