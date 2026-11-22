import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/payment/screens/keepz_native_payment_screen.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() {
    Get.reset();
  });

  for (final String? closeStatus in <String?>[null, 'success', 'fail']) {
    testWidgets(
      'hosted wallet sheet returns $closeStatus without order navigation',
      (tester) async {
        String? result = 'waiting';
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/wallet-test',
            getPages: <GetPage<dynamic>>[
              GetPage<dynamic>(
                name: '/wallet-test',
                page: () => Scaffold(
                  body: Column(
                    children: <Widget>[
                      const Text('wallet-underlay'),
                      TextButton(
                        onPressed: () async {
                          result = await KeepzPaymentLauncher.showHosted(
                            initialUrl:
                                'https://mili.ge/payment/keepz/pay/?payment_id=test',
                            resolvePaymentStatus: () async => null,
                            paymentContentBuilder: (context) => Material(
                              child: TextButton(
                                key: const Key('wallet-payment-close'),
                                onPressed: () =>
                                    Navigator.of(context).pop(closeStatus),
                                child: const Text('close-wallet-payment'),
                              ),
                            ),
                          );
                        },
                        child: const Text('add-fund'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('add-fund'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('wallet-payment-close')));
        await tester.pumpAndSettle();
        expect(result, closeStatus);
        expect(find.text('wallet-underlay'), findsOneWidget);
        expect(Get.currentRoute, '/wallet-test');
        expect(find.byKey(const Key('wallet-payment-close')), findsNothing);
      },
    );
  }

  for (final bool systemBack in <bool>[false, true]) {
    testWidgets(
      'Keepz ${systemBack ? 'back' : 'X'} closes only its modal, not the parcel screen',
      (tester) async {
        String? result = 'not-returned';
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/parcel',
            getPages: <GetPage<dynamic>>[
              GetPage<dynamic>(
                name: '/parcel',
                page: () => Scaffold(
                  body: Column(
                    children: <Widget>[
                      const Text('parcel-underlay'),
                      TextButton(
                        onPressed: () async {
                          result = await KeepzPaymentLauncher.show(
                            orderModel: OrderModel(id: 7, orderType: 'parcel'),
                            isCashOnDelivery: false,
                            paymentMethod: 'keepz',
                            guestId: '',
                            contactNumber: '',
                            createAccount: false,
                            paymentContentBuilder: (context) => Material(
                              child: TextButton(
                                key: const Key('payment-close'),
                                onPressed: () =>
                                    Navigator.of(context).pop('dismissed'),
                                child: const Text('close-owned-sheet'),
                              ),
                            ),
                          );
                        },
                        child: const Text('pay'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('pay'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('payment-close')), findsOneWidget);
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byKey(const Key('payment-close')));
        }
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(find.text('parcel-underlay'), findsOneWidget);
        expect(find.byKey(const Key('payment-close')), findsNothing);
        expect(Get.currentRoute, '/parcel');
      },
    );
  }
}
