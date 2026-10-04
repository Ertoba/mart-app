import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MILI direct prescription autosave reconciliation', () {
    String checkoutControllerSource() => File(
      'lib/features/checkout/controllers/checkout_controller.dart',
    ).readAsStringSync();

    String directPickerBlock() {
      final String source = checkoutControllerSource();

      const String startMarker =
          'void pickPrescriptionImage('
          '{required bool isRemove, required bool isCamera}) async {';

      const String endMarker =
          'Future<List<XFile>?> '
          'pickMultiplePrescriptionImages(';

      final int start = source.indexOf(startMarker);
      final int end = source.indexOf(endMarker, start);

      expect(start, greaterThanOrEqualTo(0));
      expect(end, greaterThan(start));

      return source.substring(start, end);
    }

    test('direct picker delegates to V4.2 autosave pipeline', () {
      final String block = directPickerBlock();

      expect(
        block,
        contains('await addPrescriptionImages('),
      );

      expect(
        block,
        contains('<XFile>[xFile]'),
      );

      expect(
        block,
        contains(
          'isAutoSaved: AuthHelper.isLoggedIn()',
        ),
      );
    });

    test('direct picker no longer inserts unsaved rows manually', () {
      final String block = directPickerBlock();

      expect(
        block,
        isNot(
          contains('_pickedPrescriptions.add(xFile);'),
        ),
      );

      expect(
        block,
        isNot(
          contains(
            '_pickedPrescriptionSavedImageNames.add(null);',
          ),
        ),
      );

      expect(
        block,
        isNot(
          contains(
            '_pickedPrescriptionFromMediaLibrary.add(false);',
          ),
        ),
      );
    });

    test('V4.2 autosave upload pipeline stays intact', () {
      final String source = checkoutControllerSource();

      expect(
        source,
        contains(
          'if(isAutoSaved && filesToSave.isNotEmpty)',
        ),
      );

      expect(
        source,
        contains(
          'newlySavedNames = '
          'await _saveToMediaLibrary(filesToSave);',
        ),
      );

      expect(
        source,
        contains(
          '_mergeSavedImageNames('
          'limitedPayload.savedNames, newlySavedNames)',
        ),
      );
    });

    test('V4.2 dedupe and five-file limits stay intact', () {
      final String source = checkoutControllerSource();

      expect(
        source,
        contains(
          'static const int maxPrescriptionFileCount = 5;',
        ),
      );

      expect(
        source,
        contains('_getUniquePrescriptionPayload('),
      );

      expect(
        source,
        contains('_limitPrescriptionPayload('),
      );
    });

    test('logged-in preview autosave defaults remain preserved', () {
      final String mobilePreview = File(
        'lib/features/checkout/widgets/'
        'prescription_preview_widget.dart',
      ).readAsStringSync();

      final String desktopPreview = File(
        'lib/features/checkout/widgets/'
        'desktop_prescription_preview_dialog.dart',
      ).readAsStringSync();

      expect(
        mobilePreview,
        contains(
          'bool isAutoSaved = '
          'AuthHelper.isLoggedIn() ? true : false;',
        ),
      );

      expect(
        desktopPreview,
        contains(
          'bool isAutoSaved = '
          'AuthHelper.isLoggedIn() ? true : false;',
        ),
      );
    });

    test('iOS direct upload still routes through direct picker', () {
      final String source = File(
        'lib/features/checkout/widgets/'
        'upload_prescription_widget.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          'checkoutController.pickPrescriptionImage('
          'isRemove: false, isCamera: false);',
        ),
      );
    });
  });
}
