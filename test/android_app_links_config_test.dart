import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Source-level intent-scope guards. Real App Links verification also requires
// the public HTTPS statement, the Play app-signing key, and a device check.
void main() {
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync().replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
  final activities = _blocks(manifest, 'activity');
  final main = activities.singleWhere(
    (activity) => _attributes(activity)['android:name'] == '.MainActivity',
  );
  final appLinks = _blocks(main, 'intent-filter')
      .where((filter) => _attributes(filter)['android:autoVerify'] == 'true')
      .toList();

  test('Customer has one exported, verifiable MILI domain intent filter', () {
    expect(_attributes(main)['android:exported'], 'true');
    expect(appLinks, hasLength(1));
    final filter = appLinks.single;
    expect(_values(filter, 'action', 'android:name'), {
      'android.intent.action.VIEW',
    });
    expect(_values(filter, 'category', 'android:name'), {
      'android.intent.category.DEFAULT',
      'android.intent.category.BROWSABLE',
    });
    expect(_values(filter, 'data', 'android:scheme'), {'http', 'https'});
    expect(_values(filter, 'data', 'android:host'), {'mili.ge'});
    expect(_values(filter, 'data', 'android:port'), isEmpty);
  });

  test(
    'verified links contain only the explicitly supported content routes',
    () {
      final filter = appLinks.single;
      expect(_values(filter, 'data', 'android:path'), {
        '/',
        '/store',
        '/item-details',
        '/refer-and-earn',
      });
      expect(_values(filter, 'data', 'android:pathPrefix'), {
        '/store/',
        '/item-details/',
      });
      for (final pattern in [
        'android:pathPattern',
        'android:pathAdvancedPattern',
        'android:pathSuffix',
      ]) {
        expect(_values(filter, 'data', pattern), isEmpty);
      }
    },
  );

  for (final url in [
    'https://mili.ge/?module=sakvebi',
    'http://mili.ge/?module=grocery',
    'https://mili.ge/store?id=42&module=sakvebi',
    'https://mili.ge/store/example?id=42&module=sakvebi',
    'https://mili.ge/item-details?id=123&module=sakvebi',
    'https://mili.ge/item-details/example?id=123&module=sakvebi',
    'https://mili.ge/refer-and-earn?code=sample',
  ]) {
    test('content App Link is declared: $url', () {
      expect(_matchesAppLink(appLinks.single, Uri.parse(url)), isTrue);
    });
  }

  for (final url in [
    'https://mili.ge/payment',
    'https://mili.ge/payment/callback',
    'https://mili.ge/keepz/callback',
    'https://mili.ge/digital-payment',
    'https://mili.ge/add-fund',
    'https://mili.ge/wallet',
    'https://mili.ge/checkout',
    'https://mili.ge/api/v1/payment',
    'https://mili.ge/admin',
    'https://mili.ge/.well-known/assetlinks.json',
    'https://mili.ge/store-registration',
    'https://mili.ge/store-review',
    'https://mili.ge/item-details-malicious',
    'https://mili.ge/refer-and-earn/other',
    'https://mili.ge.evil.example/store/example',
    'https://www.mili.ge/store/example',
    'https://admin.mili.ge/store/example',
    'signinwithapple://callback?code=sample',
  ]) {
    test('non-content URL is not claimed by Customer App Links: $url', () {
      expect(_matchesAppLink(appLinks.single, Uri.parse(url)), isFalse);
    });
  }

  test(
    'Apple callback matches the plugin host, not every URL of that scheme',
    () {
      final callback = activities.singleWhere(
        (activity) =>
            _attributes(activity)['android:name'] ==
            'com.aboutyou.dart_packages.sign_in_with_apple.SignInWithAppleCallback',
      );
      expect(_attributes(callback)['android:exported'], 'true');
      final filter = _blocks(callback, 'intent-filter').single;
      expect(_attributes(filter)['android:autoVerify'], isNull);
      expect(_values(filter, 'data', 'android:scheme'), {'signinwithapple'});
      expect(_values(filter, 'data', 'android:host'), {'callback'});
      expect(_values(filter, 'data', 'android:path'), isEmpty);
      expect(
        _values(main, 'data', 'android:scheme'),
        isNot(contains('signinwithapple')),
      );
    },
  );

  test('app_links remains the only Flutter deep-link consumer', () {
    final metadata = _tags(main, 'meta-data').singleWhere(
      (tag) => tag['android:name'] == 'flutter_deeplinking_enabled',
    );
    expect(metadata['android:value'], 'false');
  });
}

List<String> _blocks(String source, String name) => RegExp(
  '<$name\\b[^>]*>[\\s\\S]*?</$name>',
).allMatches(source).map((match) => match.group(0)!).toList();

Map<String, String> _attributes(String block) {
  final start = block.substring(0, block.indexOf('>') + 1);
  return {
    for (final match in RegExp(r'([\w:-]+)="([^"]*)"').allMatches(start))
      match.group(1)!: match.group(2)!,
  };
}

List<Map<String, String>> _tags(String source, String name) => RegExp(
  '<$name\\b[^>]*>',
).allMatches(source).map((match) => _attributes(match.group(0)!)).toList();

Set<String> _values(String source, String tag, String attribute) => _tags(
  source,
  tag,
).map((attributes) => attributes[attribute]).whereType<String>().toSet();

// Android merges data attributes within one filter; paths/prefixes are ORed.
// Patterns are forbidden above so this deliberately models only exact/prefix.
bool _matchesAppLink(String filter, Uri uri) {
  if (!_values(filter, 'data', 'android:scheme').contains(uri.scheme) ||
      !_values(filter, 'data', 'android:host').contains(uri.host)) {
    return false;
  }
  return _values(filter, 'data', 'android:path').contains(uri.path) ||
      _values(filter, 'data', 'android:pathPrefix').any(uri.path.startsWith);
}
