import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/order/domain/repositories/order_repository.dart';
import 'package:sixam_mart/features/order/domain/services/order_service.dart';
import 'package:sixam_mart/features/order/helper/route_polyline.dart';

class _DirectionClient extends ApiClient {
  _DirectionClient(SharedPreferences preferences)
    : super(
        appBaseUrl: 'https://example.invalid',
        sharedPreferences: preferences,
      );
  Response response = const Response(statusCode: 403);
  bool? handledGlobally;

  @override
  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool handleError = true,
    bool moduleScoped = false,
    bool rawBody = false,
  }) async {
    handledGlobally = handleError;
    return response;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _DirectionClient client;
  late OrderService service;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    client = _DirectionClient(await SharedPreferences.getInstance());
    service = OrderService(
      orderRepositoryInterface: OrderRepository(apiClient: client),
    );
  });

  test(
    'direction failures stay with the route UI, not global API navigation',
    () async {
      await expectLater(
        service.getDirectionPolyline(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
        ),
        throwsA(
          isA<RoutePolylineException>().having(
            (error) => error.failure,
            'failure',
            RouteFailure.response,
          ),
        ),
      );
      expect(client.handledGlobally, isFalse);
    },
  );

  test(
    'zero routes is a valid no-route response, not a transport failure',
    () async {
      client.response = const Response(statusCode: 200, body: {'routes': []});
      expect(
        await service.getDirectionPolyline(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
        ),
        isEmpty,
      );
    },
  );

  test('malformed geometry is an explicit route error', () async {
    client.response = const Response(
      statusCode: 200,
      body: {'encoded_polyline': '_'},
    );
    await expectLater(
      service.getDirectionPolyline(
        origin: const LatLng(0, 0),
        destination: const LatLng(1, 1),
      ),
      throwsA(
        isA<RoutePolylineException>().having(
          (error) => error.failure,
          'failure',
          RouteFailure.malformed,
        ),
      ),
    );
  });
}
