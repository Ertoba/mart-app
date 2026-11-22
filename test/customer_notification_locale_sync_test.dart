import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/domain/models/language_model.dart';
import 'package:sixam_mart/features/language/domain/service/language_service_interface.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/services/profile_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/splash/domain/services/splash_service_interface.dart';

class _LanguageService extends Fake implements LanguageServiceInterface {
  Locale saved = const Locale('en', 'US');
  String? header;
  @override
  Locale getLocaleFromSharedPref() => saved;
  @override
  bool setLTR(Locale locale) => true;
  @override
  int setSelectedIndex(List<LanguageModel> languages, Locale locale) => 0;
  @override
  void updateHeader(Locale locale, int? moduleId) {
    header = locale.languageCode;
  }

  @override
  void saveLanguage(Locale locale) {
    saved = locale;
  }
}

class _AuthService extends Fake implements AuthServiceInterface {
  @override
  bool isSharedPrefNotificationActive() => true;
}

class _Auth extends AuthController {
  final bool loggedIn;
  _Auth(this.loggedIn) : super(authServiceInterface: _AuthService());
  @override
  bool isLoggedIn() => loggedIn;
}

class _SplashService extends Fake implements SplashServiceInterface {}

class _Splash extends SplashController {
  _Splash() : super(splashServiceInterface: _SplashService());
  @override
  List<ModuleModel> get moduleList => <ModuleModel>[];
}

class _ProfileService extends Fake implements ProfileServiceInterface {}

class _Profile extends ProfileController {
  final _LanguageService language;
  final bool offline;
  int refreshes = 0;
  String? refreshedLanguage;
  _Profile(this.language, {this.offline = false})
    : super(profileServiceInterface: _ProfileService());
  @override
  Future<void> getUserInfo() async {
    refreshes++;
    refreshedLanguage = language.header;
    if (offline) throw StateError('offline');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    Get.put<SharedPreferences>(await SharedPreferences.getInstance());
    Get.put<SplashController>(_Splash());
  });
  tearDown(() => Get.reset());

  for (final bool loggedIn in <bool>[true, false]) {
    testWidgets(
      'committed customer language syncs profile only when authenticated=$loggedIn',
      (tester) async {
        final language = _LanguageService();
        final profile = _Profile(language);
        Get.put<AuthController>(_Auth(loggedIn));
        Get.put<ProfileController>(profile);
        final controller = Get.put(
          LocalizationController(
            languageServiceInterface: language,
            loadLocale: (_) async {},
          ),
        );
        await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
        await tester.runAsync(
          () => controller.setLanguage(
            const Locale('ka', 'GE'),
            fromBottomSheet: true,
          ),
        );
        expect(
          profile.refreshes,
          0,
          reason: 'Preview must not alter recipient push language.',
        );
        expect(language.saved.languageCode, 'en');
        await tester.runAsync(
          () => controller.setLanguage(const Locale('ka', 'GE')),
        );
        expect(language.saved.languageCode, 'ka');
        expect(profile.refreshes, loggedIn ? 1 : 0);
        if (loggedIn) {
          expect(
            profile.refreshedLanguage,
            'ka',
            reason: 'Header must change before profile request.',
          );
        }
      },
    );
  }
  testWidgets(
    'offline profile synchronization cannot block local language selection',
    (tester) async {
      final language = _LanguageService();
      Get.put<AuthController>(_Auth(true));
      Get.put<ProfileController>(_Profile(language, offline: true));
      final controller = Get.put(
        LocalizationController(
          languageServiceInterface: language,
          loadLocale: (_) async {},
        ),
      );
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      await tester.runAsync(
        () => controller.setLanguage(const Locale('ka', 'GE')),
      );
      expect(controller.locale.languageCode, 'ka');
      expect(language.saved.languageCode, 'ka');
    },
  );
}
