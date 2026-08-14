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
    if (isBeerModule) {
      return _localized(
        en: 'Order again from the bar you recently ordered from',
        ka: 'შეიძინეთ ბარიდან, საიდანაც ბოლოს შეუკვეთეთ',
        ru: 'Закажите снова в баре, где вы заказывали в последний раз',
        es: 'Vuelve a pedir en el bar donde hiciste tu último pedido',
        ar: 'اطلب مجددًا من البار الذي طلبت منه مؤخرًا',
        bn: 'যে বার থেকে সর্বশেষ অর্ডার করেছিলেন, সেখান থেকে আবার অর্ডার করুন',
      );
    }
    if (isPharmacyModule) {
      return _localized(
        en: 'Order again from the pharmacy you recently ordered from',
        ka: 'შეიძინეთ ისევ იმ აფთიაქში, საიდანაც ბოლოს შეუკვეთეთ',
        ru: 'Закажите снова в аптеке, где вы заказывали в последний раз',
        es: 'Vuelve a pedir en la farmacia donde hiciste tu último pedido',
        ar: 'اطلب مجددًا من الصيدلية التي طلبت منها مؤخرًا',
        bn: 'যে ফার্মেসি থেকে সর্বশেষ অর্ডার করেছিলেন, সেখান থেকে আবার অর্ডার করুন',
      );
    }
    if (isRestaurantModule) {
      return _localized(
        en: 'Order again from the restaurant you recently ordered from',
        ka: 'შეუკვეთეთ ისევ იმ რესტორანში, საიდანაც ბოლოს შეუკვეთეთ',
        ru: 'Закажите снова в ресторане, где вы заказывали в последний раз',
        es: 'Vuelve a pedir en el restaurante donde hiciste tu último pedido',
        ar: 'اطلب مجددًا من المطعم الذي طلبت منه مؤخرًا',
        bn: 'যে রেস্তোরাঁ থেকে সর্বশেষ অর্ডার করেছিলেন, সেখান থেকে আবার অর্ডার করুন',
      );
    }
    return 'get_your_recent_purchase_from_the_shop_you_recently_ordered'.tr;
  }

  static String get itemThatYouLoveLabel {
    if (isBeerModule) {
      return 'item_that_you_love'.tr;
    }
    if ((Get.locale?.languageCode ?? '').toLowerCase() == 'ka') {
      return 'ნივთები, რომლებიც მოგეწონებათ';
    }
    return 'item_that_you_love'.tr;
  }

  static String get bestStoreNearbyLabel {
    if (isBeerModule) {
      return 'best_bar_nearby'.tr;
    }
    if (isPharmacyModule) {
      return _localized(
        en: 'Best Pharmacies Nearby',
        ka: 'საუკეთესო ახლომდებარე აფთიაქები',
        ru: 'Лучшие аптеки поблизости',
        es: 'Mejores farmacias cercanas',
        ar: 'أفضل الصيدليات القريبة',
        bn: 'কাছাকাছি সেরা ফার্মেসি',
      );
    }
    if (isRestaurantModule) {
      return _localized(
        en: 'Best Restaurant Nearby',
        ka: 'საუკეთესო ახლომდებარე რესტორანი',
        ru: 'Лучший ресторан поблизости',
        es: 'Mejor restaurante cercano',
        ar: 'أفضل مطعم قريب',
        bn: 'কাছাকাছি সেরা রেস্তোরাঁ',
      );
    }
    return 'best_store_nearby'.tr;
  }

  static String get recommendedStoreLabel {
    if (isBeerModule) {
      return _localized(
        en: 'Recommended Bar',
        ka: 'რეკომენდებული ბარი',
        ru: 'Рекомендуемый бар',
        es: 'Bar recomendado',
        ar: 'بار موصى به',
        bn: 'প্রস্তাবিত বার',
      );
    }
    if (isPharmacyModule) {
      return _localized(
        en: 'Recommended Pharmacy',
        ka: 'რეკომენდებული აფთიაქი',
        ru: 'Рекомендуемая аптека',
        es: 'Farmacia recomendada',
        ar: 'صيدلية موصى بها',
        bn: 'প্রস্তাবিত ফার্মেসি',
      );
    }
    if (isRestaurantModule) {
      return _localized(
        en: 'Recommended Restaurant',
        ka: 'რეკომენდებული რესტორანი',
        ru: 'Рекомендуемый ресторан',
        es: 'Restaurante recomendado',
        ar: 'مطعم موصى به',
        bn: 'প্রস্তাবিত রেস্তোরাঁ',
      );
    }
    return 'recommended_store'.tr;
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
