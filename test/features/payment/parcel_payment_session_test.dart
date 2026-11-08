import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/parcel/domain/services/parcel_payment_session.dart';

void main() {
  for (final String state in <String>[
    'active',
    'unknown',
    'blocked',
    'superseded',
  ]) {
    test(
      'a canceled parcel with $state provider state cannot release its payment',
      () async {
        final session = ParcelPaymentSession();
        await session.run(
          signature: 'same',
          createOrder: () async => const ParcelPaymentOrder(orderId: '7'),
          showPayment: (_) async => null,
        );
        expect(
          session.releaseResolvedOrder(
            statusCode: 200,
            body: <String, dynamic>{
              'order_id': 7,
              'state': state,
              'payment_status': 'unpaid',
              'order_status': 'canceled',
            },
          ),
          isFalse,
        );
        expect(session.pending?.orderId, '7');
      },
    );
  }
  test(
    'only matching paid or safely canceled Backend orders release pending checkout',
    () async {
      final session = ParcelPaymentSession();
      Future<void> pending() async {
        await session.run(
          signature: 'same',
          createOrder: () async => const ParcelPaymentOrder(orderId: '7'),
          showPayment: (_) async => null,
        );
      }

      await pending();
      final canceled = <String, dynamic>{
        'order_id': 7,
        'state': 'ready',
        'payment_status': 'unpaid',
        'order_status': 'canceled',
      };
      expect(
        session.releaseResolvedOrder(statusCode: 409, body: canceled),
        isFalse,
      );
      expect(
        session.releaseResolvedOrder(
          statusCode: 200,
          body: <String, dynamic>{...canceled, 'order_id': 8},
        ),
        isFalse,
      );
      expect(
        session.releaseResolvedOrder(statusCode: 200, body: canceled),
        isTrue,
      );
      expect(session.pending, isNull);
      await pending();
      expect(
        session.releaseResolvedOrder(
          statusCode: 200,
          body: <String, dynamic>{
            'order_id': 7,
            'state': 'paid',
            'payment_status': 'paid',
            'order_status': 'pending',
          },
        ),
        isTrue,
      );
    },
  );
  for (final String? status in <String?>[null, 'cancel', 'dismissed', 'fail']) {
    test('retry after $status reopens the same placed order', () async {
      final session = ParcelPaymentSession();
      int creates = 0;
      final seen = <String>[];
      Future<ParcelPaymentOrder?> create() async =>
          ParcelPaymentOrder(orderId: '${++creates}', createUserId: 41);
      Future<String?> show(ParcelPaymentOrder order) async {
        seen.add(order.orderId);
        expect(order.createUserId, 41);
        return status;
      }

      expect(
        await session.run(
          signature: 'same',
          createOrder: create,
          showPayment: show,
        ),
        '1',
      );
      expect(
        await session.run(
          signature: 'same',
          createOrder: create,
          showPayment: show,
        ),
        '1',
      );
      expect(creates, 1);
      expect(seen, <String>['1', '1']);
      expect(session.pending?.orderId, '1');
    });
  }

  test('rapid repeated taps create and present only once', () async {
    final session = ParcelPaymentSession();
    final creation = Completer<ParcelPaymentOrder?>();
    final payment = Completer<String?>();
    int creates = 0;
    int shows = 0;
    Future<ParcelPaymentOrder?> create() {
      creates++;
      return creation.future;
    }

    Future<String?> show(ParcelPaymentOrder order) {
      shows++;
      return payment.future;
    }

    final first = session.run(
      signature: 'same',
      createOrder: create,
      showPayment: show,
    );
    final second = session.run(
      signature: 'same',
      createOrder: create,
      showPayment: show,
    );
    expect(identical(first, second), isTrue);
    creation.complete(const ParcelPaymentOrder(orderId: '7'));
    await Future<void>.delayed(Duration.zero);
    payment.complete(null);
    expect(await first, '7');
    expect(await second, '7');
    expect(creates, 1);
    expect(shows, 1);
  });

  test(
    'a changed draft cannot create another order or pay old addresses',
    () async {
      final session = ParcelPaymentSession();
      int creates = 0;
      int shows = 0;
      Future<ParcelPaymentOrder?> create() async {
        creates++;
        return const ParcelPaymentOrder(orderId: '7');
      }

      Future<String?> show(ParcelPaymentOrder order) async {
        shows++;
        return null;
      }

      await session.run(
        signature: 'original',
        createOrder: create,
        showPayment: show,
      );
      await expectLater(
        session.run(
          signature: 'changed-address',
          createOrder: create,
          showPayment: show,
        ),
        throwsA(isA<ParcelPaymentDraftChanged>()),
      );
      expect(creates, 1);
      expect(shows, 1);
      expect(session.pending?.orderId, '7');
    },
  );

  test(
    'presentation errors preserve the order and release the tap guard',
    () async {
      final session = ParcelPaymentSession();
      int creates = 0;
      Future<ParcelPaymentOrder?> create() async {
        creates++;
        return const ParcelPaymentOrder(orderId: '7');
      }

      await expectLater(
        session.run(
          signature: 'same',
          createOrder: create,
          showPayment: (_) async => throw StateError('offline'),
        ),
        throwsStateError,
      );
      expect(session.pending?.orderId, '7');
      expect(
        await session.run(
          signature: 'same',
          createOrder: create,
          showPayment: (_) async => null,
        ),
        '7',
      );
      expect(creates, 1);
    },
  );

  test('only backend-verified success releases the placed order', () async {
    final session = ParcelPaymentSession();
    int creates = 0;
    Future<ParcelPaymentOrder?> create() async =>
        ParcelPaymentOrder(orderId: '${++creates}');
    await session.run(
      signature: 'first',
      createOrder: create,
      showPayment: (_) async => 'success',
    );
    expect(session.pending, isNull);
    expect(
      await session.run(
        signature: 'new',
        createOrder: create,
        showPayment: (_) async => null,
      ),
      '2',
    );
    expect(creates, 2);
  });

  test(
    'an unsuccessful create has no pending payment and does not open a sheet',
    () async {
      final session = ParcelPaymentSession();
      expect(
        await session.run(
          signature: 'first',
          createOrder: () async => null,
          showPayment: (_) async => throw StateError('must not open'),
        ),
        '',
      );
      expect(session.pending, isNull);
    },
  );
}
