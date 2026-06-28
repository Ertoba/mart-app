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

  static bool get isBeerModule {
    final ModuleModel? module = getModule() ?? getCacheModule();
    final String moduleType = (module?.moduleType ?? '').trim().toLowerCase();
    final String slug = (module?.slug ?? '').trim().toLowerCase();
    final String name = (module?.moduleName ?? '').trim().toLowerCase();

    return moduleType == 'food' &&
        (slug == 'ludi' || slug == 'beer' || name == 'ლუდი' || name == 'beer');
  }

  static String get storeKey {
    if (isBeerModule) {
      return 'bar';
    }
    return showRestaurantText ? 'restaurants' : 'stores';
  }

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
    return isBeerModule ? 'best_bar_nearby' : 'best_store_nearby';
  }

  static String get popularStoresKey {
    if (isBeerModule) {
      return 'popular_bars';
    }
    return showRestaurantText ? 'popular_restaurants' : 'popular_stores';
  }

  static String get storesNearYouKey {
    if (isBeerModule) {
      return 'bars_near_you';
    }
    return showRestaurantText ? 'restaurants_near_you' : 'stores_near_you';
  }

  static String get noStoreAvailableKey {
    if (isBeerModule) {
      return 'no_bar_available';
    }
    return showRestaurantText
        ? 'no_restaurant_available'
        : 'no_store_available';
  }

  static String get currentlyOpenedStoreKey {
    if (isBeerModule) {
      return 'currently_opened_bars';
    }
    return showRestaurantText
        ? 'currently_opened_restaurants'
        : 'currently_opened_stores';
  }

  static String get discountedStoreKey {
    if (isBeerModule) {
      return 'discounted_bars';
    }
    return showRestaurantText ? 'discounted_restaurants' : 'discounted_stores';
  }

  static String get recommendedStoreKey {
    if (isBeerModule) {
      return 'recommended_bars';
    }
    return showRestaurantText
        ? 'recommended_restaurants'
        : 'recommended_stores';
  }

  static String get currentlyNoRecommendedStoreAvailableKey {
    if (isBeerModule) {
      return 'currently_no_recommended_bar_available';
    }
    return showRestaurantText
        ? 'currently_no_recommended_restaurant_available'
        : 'currently_no_recommended_store_available';
  }
}
