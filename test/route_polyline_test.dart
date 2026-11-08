import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/helper/route_polyline.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

void main() {
  const encoded = r'_p~iF~ps|U_ulLnnqC_mqNvxq`@';
  const road = [
    LatLng(38.5, -120.2),
    LatLng(40.7, -120.95),
    LatLng(43.252, -126.453),
  ];

  group('backend road geometry', () {
    test('decodes v2, legacy and normalized backend shapes', () {
      for (final body in [
        {
          'routes': [
            {
              'polyline': {'encodedPolyline': encoded},
            },
          ],
        },
        {
          'routes': [
            {
              'overview_polyline': {'points': encoded},
            },
          ],
        },
        {'encoded_polyline': encoded},
      ]) {
        expect(decodeRouteResponse(body), road);
      }
    });

    test(
      'empty provider routes differ from malformed and denied responses',
      () {
        expect(decodeRouteResponse({'routes': []}), isEmpty);
        expect(decodeRouteResponse({'status': 'ZERO_RESULTS'}), isEmpty);
        for (final body in [
          null,
          {},
          {
            'routes': [null],
          },
          {
            'routes': [
              {
                'polyline': {'encodedPolyline': 1},
              },
            ],
          },
          {'status': 'REQUEST_DENIED'},
          {'encoded_polyline': '_'},
          {'encoded_polyline': '??'},
        ]) {
          expect(
            () => decodeRouteResponse(body),
            throwsA(isA<RoutePolylineException>()),
          );
        }
      },
    );

    test(
      'truncated, invalid, runaway and out-of-range coordinates fail closed',
      () {
        for (final value in [
          '_',
          '????_',
          '\n???',
          '~~~~~~~~~~~~??',
          '_p~iF~ps|U_ulLnnqC_mqNvxq`',
        ]) {
          expect(
            () => decodeRoutePolyline(value),
            throwsA(isA<RoutePolylineException>()),
          );
        }
        expect(routeCoordinate('0', '0'), const LatLng(0, 0));
        for (final coords in [
          ['NaN', '1'],
          ['Infinity', '1'],
          ['91', '1'],
          ['1', '181'],
          [null, '1'],
        ]) {
          expect(routeCoordinate(coords[0], coords[1]), isNull);
        }
      },
    );
  });

  group('order endpoint contract', () {
    test('store to customer does not depend on a delivery-man assignment', () {
      final order = OrderModel(
        orderType: 'delivery',
        store: Store(latitude: '0', longitude: '12'),
        deliveryAddress: AddressModel(latitude: '10', longitude: '20'),
      );
      final endpoints = OrderRouteEndpoints.fromOrder(order)!;
      expect(endpoints.origin, const LatLng(0, 12));
      expect(endpoints.destination, const LatLng(10, 20));
    });

    test(
      'parcel goes sender to receiver without needing a store or courier',
      () {
        final order = OrderModel(
          orderType: 'parcel',
          deliveryAddress: AddressModel(latitude: '1', longitude: '2'),
          receiverDetails: AddressModel(latitude: '3', longitude: '4'),
        );
        final endpoints = OrderRouteEndpoints.fromOrder(order)!;
        expect(endpoints.origin, const LatLng(1, 2));
        expect(endpoints.destination, const LatLng(3, 4));
        order.receiverDetails!.latitude = 'broken';
        expect(OrderRouteEndpoints.fromOrder(order), isNull);
      },
    );
  });

  group('screen-local route lifecycle', () {
    test(
      'unchanged endpoints do not request again on GPS marker ticks',
      () async {
        int calls = 0;
        final controller = RoutePolylineController(
          fetch: ({required origin, required destination}) async {
            calls++;
            return road;
          },
        );
        addTearDown(controller.dispose);
        for (int tick = 0; tick < 20; tick++) {
          await controller.load(
            const LatLng(1, 2),
            const LatLng(3, 4),
            scope: 'order',
          );
        }
        expect(calls, 1);
        expect(controller.status, RouteLoadStatus.ready);
        await controller.load(
          const LatLng(1, 2),
          const LatLng(3, 4),
          scope: 'order',
          force: true,
        );
        expect(calls, 2);
      },
    );

    test('older concurrent response cannot replace newer endpoints', () async {
      final old = Completer<List<LatLng>>();
      final current = Completer<List<LatLng>>();
      final controller = RoutePolylineController(
        fetch: ({required origin, required destination}) =>
            origin.latitude == 1 ? old.future : current.future,
      );
      addTearDown(controller.dispose);
      final first = controller.load(const LatLng(1, 2), const LatLng(3, 4));
      final second = controller.load(const LatLng(5, 6), const LatLng(7, 8));
      expect(controller.status, RouteLoadStatus.loading);
      current.complete(road);
      await second;
      old.complete(const [LatLng(1, 1), LatLng(2, 2)]);
      await first;
      expect(controller.points, road);
    });

    test(
      'invalid replacement clears previous geometry and invalidates in-flight response',
      () async {
        final pending = Completer<List<LatLng>>();
        final controller = RoutePolylineController(
          fetch: ({required origin, required destination}) => pending.future,
        );
        addTearDown(controller.dispose);
        final old = controller.load(const LatLng(1, 2), const LatLng(3, 4));
        await controller.load(null, const LatLng(3, 4));
        pending.complete(road);
        await old;
        expect(controller.status, RouteLoadStatus.error);
        expect(controller.failure, RouteFailure.invalidCoordinates);
        expect(controller.points, isEmpty);
      },
    );

    test(
      'no-route, failure, timeout and explicit retry are distinct',
      () async {
        int calls = 0;
        final controller = RoutePolylineController(
          fetch: ({required origin, required destination}) async {
            calls++;
            if (calls == 1) return [];
            throw const RoutePolylineException(RouteFailure.response);
          },
        );
        addTearDown(controller.dispose);
        await controller.load(const LatLng(1, 2), const LatLng(3, 4));
        expect(controller.status, RouteLoadStatus.noRoute);
        await controller.load(
          const LatLng(1, 2),
          const LatLng(3, 4),
          force: true,
        );
        expect(controller.status, RouteLoadStatus.error);
        expect(controller.failure, RouteFailure.response);

        final timed = RoutePolylineController(
          timeout: const Duration(milliseconds: 1),
          fetch: ({required origin, required destination}) =>
              Completer<List<LatLng>>().future,
        );
        addTearDown(timed.dispose);
        await timed.load(const LatLng(1, 2), const LatLng(3, 4));
        expect(timed.status, RouteLoadStatus.error);
        expect(timed.failure, RouteFailure.timeout);
      },
    );

    test(
      'a response after dispose cannot notify or mutate a closed screen',
      () async {
        final pending = Completer<List<LatLng>>();
        final controller = RoutePolylineController(
          fetch: ({required origin, required destination}) => pending.future,
        );
        int notifications = 0;
        controller.addListener(() {
          notifications++;
        });
        final loading = controller.load(const LatLng(1, 2), const LatLng(3, 4));
        controller.dispose();
        pending.complete(road);
        await loading;
        expect(notifications, 1);
        expect(controller.points, isEmpty);
      },
    );
  });

  test('bounds include road bends rather than endpoints only', () {
    final bounds = routeBounds(const [
      LatLng(1, 4),
      LatLng(5, 2),
      LatLng(3, 8),
    ]);
    expect(bounds.southwest, const LatLng(1, 2));
    expect(bounds.northeast, const LatLng(5, 8));
  });
}
