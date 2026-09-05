import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_result_sections.dart';

void main() {
  testWidgets(
    'result cards fit large text with price comparison and store details',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.8),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: AiChatResultSections(
                  metadata: const {
                    'comparison': {},
                    'currency': {'symbol': '₾', 'position': 'right'},
                    'products': [
                      {
                        'id': 1,
                        'name': 'Long product name for a narrow card',
                        'store_name': 'Neighbourhood supermarket',
                        'price': 99.99,
                        'discounted_price': 85.99,
                        'has_discount': true,
                        'rating': 4.8,
                      },
                    ],
                    'stores': [
                      {
                        'id': 2,
                        'name': 'Neighbourhood supermarket',
                        'rating': 4.8,
                        'delivery_time': '20–30 min',
                        'minimum_order': 15,
                      },
                    ],
                  },
                  onAskAbout: (_) {},
                  onOpenProduct: (_) {},
                  onOpenStore: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('85.99 ₾'), findsOneWidget);
    },
  );
  testWidgets(
    'product result opens the selected product instead of searching again',
    (tester) async {
      Map<String, dynamic>? openedProduct;
      String? repeatedSearch;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiChatResultSections(
              metadata: const <String, dynamic>{
                'products': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 42,
                    'name': 'Test product',
                    'price': 10,
                    'discounted_price': 8,
                    'has_discount': true,
                    'in_stock': true,
                  },
                ],
              },
              onAskAbout: (value) => repeatedSearch = value,
              onOpenProduct: (product) => openedProduct = product,
              onOpenStore: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test product'));

      expect(openedProduct?['id'], 42);
      expect(repeatedSearch, isNull);
    },
  );
}
