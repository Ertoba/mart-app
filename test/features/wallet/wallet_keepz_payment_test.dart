import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/wallet/domain/models/wallet_keepz_payment.dart';

void main() {
  const String id = 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa';
  const String url = 'https://mili.ge/payment/keepz/pay/?payment_id=$id';
  WalletKeepzPayment? parse(dynamic body, {String method = 'keepz'}) =>
      WalletKeepzPayment.fromResponse(
        paymentMethod: method,
        body: body,
        baseUrl: 'https://mili.ge',
      );

  test('new wallet capability opens only its exact Keepz request', () {
    final payment = parse({
      'embedded_keepz_wallet': true,
      'redirect_link': url,
    })!;
    expect(payment.paymentId, id);
    expect(payment.redirectUrl, url);
    expect(payment.statusPath, '/api/v1/customer/wallet/payment/$id/status');
  });

  test('old servers and other gateways retain their existing flow', () {
    expect(parse({'redirect_link': url}), isNull);
    expect(
      parse({'embedded_keepz_wallet': false, 'redirect_link': url}),
      isNull,
    );
    expect(
      parse({
        'embedded_keepz_wallet': true,
        'redirect_link': url,
      }, method: 'stripe'),
      isNull,
    );
    expect(parse(null), isNull);
  });

  test('capability cannot redirect wallet into another origin or identity', () {
    for (final invalid in <String>[
      'https://evil.example/payment/keepz/pay/?payment_id=$id',
      'http://mili.ge/payment/keepz/pay/?payment_id=$id',
      'https://mili.ge:444/payment/keepz/pay/?payment_id=$id',
      'https://user@mili.ge/payment/keepz/pay/?payment_id=$id',
      'https://mili.ge/payment/stripe/pay/?payment_id=$id',
      'https://mili.ge/payment/keepz/pay/?payment_id=not-an-id',
      '$url&payment_id=bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',
      'javascript:alert(1)',
    ]) {
      expect(
        () => parse({'embedded_keepz_wallet': true, 'redirect_link': invalid}),
        throwsFormatException,
      );
    }
  });

  test(
    'success needs authenticated same-request paid AND exact ledger proof',
    () {
      const payment = WalletKeepzPayment(paymentId: id, redirectUrl: url);
      final paid = <String, dynamic>{
        'payment_id': id,
        'state': 'paid',
        'wallet_credit_confirmed': true,
        'wallet_payment_status': 'success',
      };
      expect(payment.verifiedStatus(statusCode: 200, body: paid), 'success');
      for (final invalid in <dynamic>[
        {...paid, 'payment_id': 'different'},
        {...paid, 'wallet_credit_confirmed': false},
        {...paid, 'wallet_credit_confirmed': 'true'},
        {...paid, 'wallet_payment_status': 'pending'},
        {...paid, 'state': 'settlement_pending'},
        {'status': 'success', 'flag': 'success'},
        null,
      ]) {
        expect(payment.verifiedStatus(statusCode: 200, body: invalid), isNull);
      }
      expect(payment.verifiedStatus(statusCode: 500, body: paid), isNull);
      expect(
        payment.verifiedStatus(
          statusCode: 200,
          body: {
            'payment_id': id,
            'state': 'terminal',
            'wallet_credit_confirmed': false,
          },
        ),
        'fail',
      );
      expect(
        payment.verifiedStatus(
          statusCode: 200,
          body: {
            'payment_id': id,
            'state': 'active',
            'wallet_credit_confirmed': false,
          },
        ),
        isNull,
      );
    },
  );

  test('Georgian profile has a real monthly cart translation', () {
    final Map<String, dynamic> ka = jsonDecode(
      File('assets/language/ka.json').readAsStringSync(),
    );
    expect(ka['monthly_cart_list'], 'ყოველთვიური კალათა');
  });
}
