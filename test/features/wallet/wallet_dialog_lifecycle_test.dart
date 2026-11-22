import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet/controllers/wallet_controller.dart';
import 'package:sixam_mart/features/wallet/domain/services/wallet_service_interface.dart';

class _WalletService extends Fake implements WalletServiceInterface {
  final Completer<Response<dynamic>> response = Completer<Response<dynamic>>();
  int requests = 0;

  @override
  Future<Response<dynamic>> addFundToWallet(
    double amount,
    String paymentMethod,
  ) {
    requests++;
    return response.future;
  }
}

void main() {
  tearDown(() => Get.reset());

  testWidgets(
    'closing amount dialog during initialization never pops wallet or opens late payment',
    (tester) async {
      Get.testMode = true;
      final service = _WalletService();
      final controller = WalletController(walletServiceInterface: service);
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                const Text('wallet-underlay'),
                TextButton(
                  onPressed: () => Get.dialog<void>(
                    Builder(
                      builder: (context) => Material(
                        child: Column(
                          children: <Widget>[
                            TextButton(
                              onPressed: () => controller.addFundToWallet(
                                10,
                                'keepz',
                                dialogContext: context,
                              ),
                              child: const Text('start-fund'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('cancel-amount'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: const Text('open-amount'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('open-amount'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('start-fund'));
      await tester.pump();
      // Repeated taps while initialization is pending cannot create another request.
      await tester.tap(find.text('start-fund'));
      expect(service.requests, 1);
      await tester.tap(find.text('cancel-amount'));
      await tester.pumpAndSettle();
      service.response.complete(
        const Response<dynamic>(
          statusCode: 201,
          body: {
            'embedded_keepz_wallet': true,
            'redirect_link':
                'https://mili.ge/payment/keepz/pay/?payment_id=aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('wallet-underlay'), findsOneWidget);
      expect(Get.isDialogOpen, false);
      expect(Get.isBottomSheetOpen, false);
      expect(controller.isLoading, false);
    },
  );
}
