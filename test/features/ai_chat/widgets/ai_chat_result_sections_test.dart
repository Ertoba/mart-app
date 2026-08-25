import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_result_sections.dart';

void main() {
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
