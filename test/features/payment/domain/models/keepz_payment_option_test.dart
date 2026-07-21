import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/payment/domain/models/keepz_payment_option.dart';

void main() {
  group('KeepzPaymentOption checkout configuration', () {
    test('exposes only the hosted checkout card entry', () {
      expect(KeepzPaymentOption.values, <KeepzPaymentOption>[
        KeepzPaymentOption.card,
      ]);
      expect(KeepzPaymentOption.card.flow, 'hosted');
      expect(KeepzPaymentOption.card.provider, isEmpty);
      expect(KeepzPaymentOption.card.title, 'ბარათით გადახდა');
    });

    test('does not restore legacy direct options from stale keys', () {
      expect(KeepzPaymentOption.fromKey('bog'), isNull);
      expect(KeepzPaymentOption.fromKey('crypto'), isNull);
      expect(KeepzPaymentOption.fromKey('card'), KeepzPaymentOption.card);
    });
  });
}
