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

  static bool get isPharmacyModule {
    final ModuleModel? module = getModule() ?? getCacheModule();
    final String moduleType = (module?.moduleType ?? '').trim().toLowerCase();
    return moduleType == 'pharmacy';
  }

  static String _localized({
    required String en,
    required String ka,
    required String ru,
    required String es,
    required String ar,
    required String bn,
  }) {
    switch ((Get.locale?.languageCode ?? 'en').toLowerCase()) {
      case 'ka':
        return ka;
      case 'ru':
        return ru;
      case 'es':
        return es;
      case 'ar':
        return ar;
      case 'bn':
        return bn;
      default:
        return en;
    }
  }

  static String get storeKey {
    if (isBeerModule) {
      return 'bar';
    }
    return showRestaurantText ? 'restaurants' : 'stores';
  }

  static String get storeLabel {
    if (!isPharmacyModule) {
      return storeKey.tr;
    }
    return _localized(
      en: 'Pharmacies',
      ka: 'აფთიაქები',
      ru: 'Аптеки',
      es: 'Farmacias',
      ar: 'الصيدليات',
      bn: 'ফার্মেসি',
    );
  }

  static String get storesNearYouLabel {
    if (!isPharmacyModule) {
      return storesNearYouKey.tr;
    }
    return _localized(
      en: 'Pharmacies near you',
      ka: 'ახლომდებარე აფთიაქები',
      ru: 'Аптеки поблизости',
      es: 'Farmacias cerca de ti',
      ar: 'صيدليات بالقرب منك',
      bn: 'আপনার কাছাকাছি ফার্মেসি',
    );
  }

  static String get recentPurchasePrompt {
    if (!isBeerModule) {
      return 'get_your_recent_purchase_from_the_shop_you_recently_ordered'.tr;
    }
    return _localized(
      en: 'Order again from the bar you recently ordered from',
      ka: 'შეიძინეთ ბარიდან, საიდანაც ბოლოს შეუკვეთეთ',
      ru: 'Закажите снова в баре, где вы заказывали в последний раз',
      es: 'Vuelve a pedir en el bar donde hiciste tu último pedido',
      ar: 'اطلب مجددًا من البار الذي طلبت منه مؤخرًا',
      bn: 'যে বার থেকে সর্বশেষ অর্ডার করেছিলেন, সেখান থেকে আবার অর্ডার করুন',
    );
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
    if (isBeerModule) {
      return 'best_bar_nearby';
    }
    return showRestaurantText ? 'restaurants_near_you' : 'best_store_nearby';
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
