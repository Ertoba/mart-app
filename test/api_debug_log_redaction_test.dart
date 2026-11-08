import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'debug telemetry logs a fixed class and HTTP status, not URL/header/body/token',
    () async {
      final messages = <String>[];
      final original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) messages.add(message);
      };
      addTearDown(() {
        debugPrint = original;
      });
      SharedPreferences.setMockInitialValues({
        AppConstants.token: 'private-test-value',
      });
      final client = ApiClient(
        appBaseUrl: 'https://example.invalid',
        sharedPreferences: await SharedPreferences.getInstance(),
      );
      const uri =
          '${AppConstants.directionUri}?origin_lat=12.345&key=private-test-value';
      final request = http.Request(
        'GET',
        Uri.parse('https://example.invalid$uri'),
      )..headers['Authorization'] = 'Bearer private-test-value';
      client.handleResponse(
        http.Response(
          '{"encoded_polyline":"private-test-value"}',
          200,
          request: request,
        ),
        uri,
        false,
      );
      expect(messages, ['api method=GET endpoint=directions status=200']);
    },
  );
}
