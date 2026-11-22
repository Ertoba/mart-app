import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/language/domain/models/language_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/language_loader.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/domain/service/language_service_interface.dart';

class LocalizationController extends GetxController implements GetxService {
  final LanguageServiceInterface languageServiceInterface;
  final Future<void> Function(Locale) _loadLocale;
  LocalizationController({
    required this.languageServiceInterface,
    Future<void> Function(Locale)? loadLocale,
  }) : _loadLocale = loadLocale ?? LanguageLoader.ensureLocaleLoaded {
    loadCurrentLanguage();
  }

  Locale _locale = Locale(
    AppConstants.languages[0].languageCode!,
    AppConstants.languages[0].countryCode,
  );
  Locale get locale => _locale;

  bool _isLtr = true;
  bool get isLtr => _isLtr;

  List<LanguageModel> _languages = [];
  List<LanguageModel> get languages => _languages;

  int _selectedLanguageIndex = 0;
  int get selectedLanguageIndex => _selectedLanguageIndex;

  Future<void> setLanguage(
    Locale locale, {
    bool fromBottomSheet = false,
  }) async {
    // Languages other than the startup pair are loaded in the background after the
    // first frame, so a user who taps one before that finishes would otherwise see
    // raw translation keys. Resolves immediately once the locale is in place.
    await _loadLocale(locale);
    Get.updateLocale(locale);
    _locale = locale;
    _isLtr = languageServiceInterface.setLTR(_locale);
    languageServiceInterface.updateHeader(
      _locale,
      Get.find<SplashController>().module?.id,
    );

    if (!fromBottomSheet) {
      saveLanguage(_locale);
    }

    if (AddressHelper.getUserAddressFromSharedPref() != null &&
        !fromBottomSheet) {
      HomeScreen.loadData(true);
    }

    if (Get.find<SplashController>().moduleList == null) {
      Get.find<SplashController>().getModules(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          AppConstants.localizationKey:
              Get.find<LocalizationController>().locale.languageCode,
        },
      );
    }

    update();
    await synchronizeNotificationLanguage(fromBottomSheet: fromBottomSheet);
  }

  Future<void> synchronizeNotificationLanguage({
    bool fromBottomSheet = false,
  }) async {
    // The profile endpoint persists the authenticated recipient's push locale.
    // Updating only the request header leaves background pushes in the old
    // language until the customer happens to open their profile again.
    if (!fromBottomSheet &&
        Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn() &&
        Get.isRegistered<ProfileController>()) {
      try {
        await Get.find<ProfileController>().getUserInfo();
      } catch (_) {
        // Local language selection must still work offline; the next ordinary
        // profile refresh will synchronize the saved locale with the backend.
      }
    }
  }

  void loadCurrentLanguage() async {
    final Locale savedLocale = languageServiceInterface
        .getLocaleFromSharedPref();
    final bool isSupported = AppConstants.languages.any(
      (language) => language.languageCode == savedLocale.languageCode,
    );
    _locale = isSupported
        ? savedLocale
        : Locale(
            AppConstants.languages[0].languageCode!,
            AppConstants.languages[0].countryCode,
          );
    if (!isSupported) {
      languageServiceInterface.saveLanguage(_locale);
    }
    _isLtr = _locale.languageCode != 'ar';
    _selectedLanguageIndex = languageServiceInterface.setSelectedIndex(
      AppConstants.languages,
      _locale,
    );
    _languages = [];
    _languages.addAll(AppConstants.languages);
    update();
  }

  void saveLanguage(Locale locale) async {
    languageServiceInterface.saveLanguage(locale);
  }

  void saveCacheLanguage(Locale? locale) {
    languageServiceInterface.saveCacheLanguage(
      locale ?? languageServiceInterface.getLocaleFromSharedPref(),
    );
  }

  void setSelectLanguageIndex(int index) {
    _selectedLanguageIndex = index;
    update();
  }

  Locale getCacheLocaleFromSharedPref() {
    return languageServiceInterface.getCacheLocaleFromSharedPref();
  }

  void searchSelectedLanguage() {
    for (var language in AppConstants.languages) {
      if (language.languageCode!.toLowerCase().contains(
        _locale.languageCode.toLowerCase(),
      )) {
        _selectedLanguageIndex = AppConstants.languages.indexOf(language);
      }
    }
  }
}
