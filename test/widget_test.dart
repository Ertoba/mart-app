import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/util/app_constants.dart';

void main() {
  test('MILI V4.2 configuration smoke test', () {
    expect(AppConstants.appVersion, 4.2);
    expect(AppConstants.appName, isNotEmpty);
    expect(AppConstants.baseUrl, 'https://mili.ge');
  });
}
