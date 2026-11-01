import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/payment/domain/models/keepz_payment_intent.dart';
import 'package:sixam_mart/features/payment/services/keepz_payment_lifecycle.dart';

void main() {
  test(
    'hosted checkout stays embedded even when bank handoff is preferred',
    () {
      final intent = KeepzPaymentIntent.fromJson({
        'url': 'https://app.keepz.me/pay?test=1',
        'action': 'bottom_sheet_webview',
      });
      expect(intent.shouldOpenBankApp(externalFirst: true), isFalse);
      expect(intent.shouldOpenBankApp(externalFirst: false), isFalse);
      const bank = KeepzPaymentIntent(
        url: 'https://bank.example/pay',
        action: 'external_non_browser',
      );
      expect(bank.shouldOpenBankApp(externalFirst: true), isTrue);
      expect(bank.shouldOpenBankApp(externalFirst: false), isFalse);
      expect(
        () => KeepzPaymentIntent.fromJson({'url': 'javascript:alert(1)'}),
        throwsFormatException,
      );
    },
  );

  test('a success redirect alone cannot declare the order paid', () async {
    String? backend;
    final lifecycle = KeepzPaymentLifecycle(
      readPaymentStatus: () async => backend,
    );
    expect(await lifecycle.resolve(terminalHint: 'success'), isNull);
    expect(lifecycle.isCompleted, isFalse);
    backend = 'success';
    expect(await lifecycle.resolve(), 'success');
    expect(lifecycle.isCompleted, isTrue);
    expect(await lifecycle.resolve(terminalHint: 'success'), isNull);
  });

  test('concurrent callbacks produce one terminal result', () async {
    final response = Completer<String?>();
    int reads = 0;
    final lifecycle = KeepzPaymentLifecycle(
      readPaymentStatus: () {
        reads++;
        return response.future;
      },
    );
    final first = lifecycle.resolve(terminalHint: 'success');
    expect(await lifecycle.resolve(terminalHint: 'success'), isNull);
    response.complete('success');
    expect(await first, 'success');
    expect(reads, 1);
  });

  test(
    'unknown and network errors can be retried without clearing payment',
    () async {
      int reads = 0;
      final lifecycle = KeepzPaymentLifecycle(
        readPaymentStatus: () async {
          if (++reads == 1) throw StateError('offline');
          return reads == 2 ? null : 'fail';
        },
      );
      expect(await lifecycle.resolve(terminalHint: 'fail'), isNull);
      expect(await lifecycle.resolve(), isNull);
      expect(await lifecycle.resolve(), 'fail');
      expect(lifecycle.isCompleted, isTrue);
    },
  );

  test('cancel is neutral and makes no provider/status write', () async {
    int reads = 0;
    final lifecycle = KeepzPaymentLifecycle(
      readPaymentStatus: () async {
        reads++;
        return 'success';
      },
    );
    expect(await lifecycle.resolve(terminalHint: 'cancel'), 'cancel');
    expect(reads, 0);
  });

  test('only successful authoritative responses can report paid', () {
    expect(
      KeepzPaymentLifecycle.backendStatus(
        statusCode: 500,
        body: {'payment_status': 'paid'},
      ),
      isNull,
    );
    expect(
      KeepzPaymentLifecycle.backendStatus(
        statusCode: 200,
        body: {'state': 'active', 'payment_status': 'unpaid'},
      ),
      isNull,
    );
    expect(
      KeepzPaymentLifecycle.backendStatus(
        statusCode: 200,
        body: {'state': 'paid'},
      ),
      'success',
    );
    expect(
      KeepzPaymentLifecycle.backendStatus(
        statusCode: 200,
        body: {'state': 'superseded'},
      ),
      'superseded',
    );
  });

  test('terminal URLs require the configured origin and exact path', () {
    String? hint(String url) => KeepzPaymentLifecycle.terminalHint(
      url,
      baseUrl: 'https://mili.ge',
      returnScheme: 'mili',
    );
    expect(hint('https://mili.ge/payment-success'), 'success');
    expect(hint('https://mili.ge/payment-fail?anything=1'), 'fail');
    expect(hint('https://mili.ge/payment-cancel'), 'cancel');
    expect(hint('https://evil.example/payment-success'), isNull);
    expect(hint('http://mili.ge/payment-success'), isNull);
    expect(hint('https://mili.ge:444/payment-success'), isNull);
    expect(hint('https://mili.ge/payment-success/forged'), isNull);
    expect(hint('mili://payment-return/order?flag=paid'), 'success');
  });
}
