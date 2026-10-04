import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'MILI app-download private-backend compatibility',
    () {
      test(
        'uses main config as V4.2 app-download source',
        () {
          final source = File(
            'lib/features/splash/controllers/'
            'splash_controller.dart',
          ).readAsStringSync();

          expect(
            source,
            contains(
              '_buildAppDownloadSectionFromConfig()',
            ),
          );

          expect(
            source,
            contains(
              'configModel?.downloadUserAppLinks',
            ),
          );

          expect(
            source,
            contains(
              "configLinks.playStoreUrlStatus == '1'",
            ),
          );

          expect(
            source,
            contains(
              "configLinks.appleStoreUrlStatus == '1'",
            ),
          );

          expect(
            source,
            contains(
              'downloadUserAppSectionStatus: 1',
            ),
          );
        },
      );

      test(
        'fetch does not call unavailable endpoint',
        () {
          final source = File(
            'lib/features/splash/controllers/'
            'splash_controller.dart',
          ).readAsStringSync();

          final start = source.indexOf(
            'Future<void> fetchAppDownloadSection() '
            'async {',
          );

          final end = source.indexOf(
            'DownloadUserAppLinks? get links',
            start,
          );

          expect(
            start,
            greaterThanOrEqualTo(0),
          );

          expect(
            end,
            greaterThan(start),
          );

          final block = source.substring(
            start,
            end,
          );

          expect(
            block,
            isNot(
              contains(
                'splashServiceInterface.'
                'getAppDownloadSection()',
              ),
            ),
          );

          expect(
            block,
            contains(
              '_buildAppDownloadSectionFromConfig()',
            ),
          );
        },
      );

      test(
        'one active app store is sufficient',
        () {
          final source = File(
            'lib/features/splash/controllers/'
            'splash_controller.dart',
          ).readAsStringSync();

          expect(
            source,
            contains(
              '(appDownloadSection?.'
              'downloadUserAppSectionStatus ?? 0) '
              '== 1',
            ),
          );

          expect(
            source,
            contains(
              '|| (links?.appleStoreUrl?.'
              'isNotEmpty ?? false)',
            ),
          );
        },
      );

      test(
        'QR widget is null safe',
        () {
          final source = File(
            'lib/features/home/widgets/web/widgets/'
            'download_qr_scanner_widget.dart',
          ).readAsStringSync();

          expect(
            source,
            isNot(
              contains(
                'qrData!.isNotEmpty',
              ),
            ),
          );

          expect(
            source,
            contains(
              'final String effectiveQrData',
            ),
          );

          expect(
            source,
            contains(
              'effectiveQrData.isNotEmpty',
            ),
          );

          expect(
            source,
            contains(
              'if(hasGooglePlay)',
            ),
          );

          expect(
            source,
            contains(
              'if(hasAppStore)',
            ),
          );
        },
      );

      test(
        'official V4.2 endpoint infrastructure '
        'remains preserved',
        () {
          final constants = File(
            'lib/util/app_constants.dart',
          ).readAsStringSync();

          final repository = File(
            'lib/features/splash/domain/repositories/'
            'splash_repository.dart',
          ).readAsStringSync();

          expect(
            constants,
            contains(
              "appDownloadSectionUri = "
              "'/api/v1/app-download-section'",
            ),
          );

          expect(
            repository,
            contains(
              'AppConstants.appDownloadSectionUri',
            ),
          );
        },
      );

      test(
        'obsolete WebLandingPage stays removed',
        () {
          expect(
            File(
              'lib/features/location/screens/'
              'web_landing_page.dart',
            ).existsSync(),
            isFalse,
          );
        },
      );
    },
  );
}
