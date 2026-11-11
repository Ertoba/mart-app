import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Source-level regression guards only. The release build must also verify its
// merged manifest; these assertions do not prove runtime network behavior.
void main() {
  group('Android advertising privacy configuration', () {
    late String manifest;

    setUp(() {
      manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
    });

    test(
      'uses the pre-provider privacy Application and manifest merger tools',
      () {
        final manifestAttributes = _tags(manifest, 'manifest').single;
        final application = _tags(manifest, 'application').single;

        expect(
          manifestAttributes['xmlns:tools'],
          'http://schemas.android.com/tools',
        );
        expect(
          application['android:name'],
          anyOf('.MiliApplication', 'ge.mili.customer.MiliApplication'),
        );
      },
    );

    for (final permission in const [
      'com.google.android.gms.permission.AD_ID',
      'android.permission.ACCESS_ADSERVICES_AD_ID',
      'android.permission.ACCESS_ADSERVICES_ATTRIBUTION',
      'android.permission.ACCESS_ADSERVICES_CUSTOM_AUDIENCE',
      'android.permission.ACCESS_ADSERVICES_TOPICS',
    ]) {
      test('removes inherited permission $permission', () {
        final declarations = _namedTags(
          manifest,
          'uses-permission',
          permission,
        );

        expect(declarations.length, 1, reason: permission);
        expect(declarations.single['tools:node'], 'remove', reason: permission);
      });
    }

    for (final setting in const [
      'AutoInitEnabled',
      'AutoLogAppEventsEnabled',
      'AdvertiserIDCollectionEnabled',
      'AutoLogMetaDataEnabled',
      'AutoLogProductImprovementEnabled',
    ]) {
      test('disables Facebook $setting in manifest metadata', () {
        final name = 'com.facebook.sdk.$setting';
        final declarations = _namedTags(manifest, 'meta-data', name);

        expect(declarations.length, 1, reason: name);
        expect(declarations.single['android:value'], 'false', reason: name);
      });
    }

    test(
      'sets all Facebook privacy flags in attachBaseContext, not onCreate',
      () {
        final source = _withoutComments(
          File(
            'android/app/src/main/kotlin/ge/mili/customer/'
            'MiliApplication.kt',
          ).readAsStringSync(),
        );

        expect(
          RegExp(
            r'class\s+MiliApplication\s*:\s*Application\s*\(\s*\)',
          ).hasMatch(source),
          isTrue,
          reason:
              'MiliApplication must retain the standard Android Application.',
        );
        expect(
          RegExp(r'override\s+fun\s+attachBaseContext\s*\(').hasMatch(source),
          isTrue,
          reason:
              'ContentProvider startup happens before Application.onCreate.',
        );

        final attachBaseContext = _methodBody(source, 'attachBaseContext');
        expect(
          RegExp(r'super\.attachBaseContext\s*\(').hasMatch(attachBaseContext),
          isTrue,
        );

        for (final setter in const [
          'setAutoInitEnabled',
          'setAutoLogAppEventsEnabled',
          'setAdvertiserIDCollectionEnabled',
          'setAutoLogMetaDataEnabled',
          'setAutoLogProductImprovementEnabled',
        ]) {
          expect(
            RegExp(
              'FacebookSdk\\.${RegExp.escape(setter)}\\s*\\(\\s*false\\s*\\)',
            ).hasMatch(attachBaseContext),
            isTrue,
            reason:
                '$setter(false) must run before Android installs providers.',
          );
        }
      },
    );

    test(
      'pins the inspected Facebook SDK instead of resolving latest.release',
      () {
        final gradle = _withoutComments(
          File('android/app/build.gradle.kts').readAsStringSync(),
        );
        final versions = RegExp(
          r'com\.facebook\.android:facebook-android-sdk:([^"\s)]+)',
        ).allMatches(gradle).map((match) => match.group(1)).toList();

        expect(versions, ['19.0.1']);
      },
    );

    test('retains Flutter launch, Maps, location and FCM declarations', () {
      final activities = _tags(manifest, 'activity');
      expect(
        activities.any(
          (attributes) =>
              attributes['android:name'] == '.MainActivity' &&
              attributes['android:exported'] == 'true',
        ),
        isTrue,
      );
      expect(
        _namedTags(
          manifest,
          'meta-data',
          'flutterEmbedding',
        ).single['android:value'],
        '2',
      );
      for (final name in const [
        'com.google.android.geo.API_KEY',
        'com.google.firebase.messaging.default_notification_icon',
        'com.google.firebase.messaging.default_notification_channel_id',
      ]) {
        // Check declaration names only; never display API/resource values.
        expect(_namedTags(manifest, 'meta-data', name).length, 1, reason: name);
      }
      for (final permission in const [
        'android.permission.INTERNET',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.ACCESS_COARSE_LOCATION',
      ]) {
        final declarations = _namedTags(
          manifest,
          'uses-permission',
          permission,
        );
        expect(declarations.length, 1, reason: permission);
        expect(
          declarations.single['tools:node'] == 'remove',
          isFalse,
          reason: '$permission must remain available to core functionality.',
        );
      }
      expect(
        _namedTags(manifest, 'action', 'FLUTTER_NOTIFICATION_CLICK').length,
        1,
      );
    });
  });
}

List<Map<String, String>> _tags(String xml, String tag) {
  return RegExp(
    '<${RegExp.escape(tag)}\\b[^>]*>',
  ).allMatches(xml.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '')).map((match) {
    final attributes = <String, String>{};
    for (final attribute in RegExp(
      r'([\w:.-]+)\s*=\s*"([^"]*)"',
    ).allMatches(match.group(0)!)) {
      attributes[attribute.group(1)!] = attribute.group(2)!;
    }
    return attributes;
  }).toList();
}

List<Map<String, String>> _namedTags(String xml, String tag, String name) {
  return _tags(
    xml,
    tag,
  ).where((attributes) => attributes['android:name'] == name).toList();
}

String _withoutComments(String source) {
  return source.replaceAll(RegExp(r'/\*[\s\S]*?\*/|//[^\r\n]*'), '');
}

String _methodBody(String source, String method) {
  final signature = RegExp(
    'override\\s+fun\\s+${RegExp.escape(method)}\\s*\\([^)]*\\)\\s*\\{',
  ).firstMatch(source);
  expect(signature != null, isTrue, reason: '$method override is required.');

  var depth = 1;
  final start = signature!.end;
  for (var index = start; index < source.length; index++) {
    if (source[index] == '{') depth++;
    if (source[index] == '}') depth--;
    if (depth == 0) return source.substring(start, index);
  }
  fail('$method must have a complete method body.');
}
