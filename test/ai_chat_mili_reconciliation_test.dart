import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MILI AI V4.2 reconciliation', () {
    test('AI is available on Home while preserving V4.2 service support', () {
      final String source = File(
        'lib/features/dashboard/screens/dashboard_screen.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          'final bool isHomeLanding = '
          'splashController.selectedModuleIndex == 0;',
        ),
      );

      expect(
        source,
        contains(
          '&& (isHomeLanding || '
          '(moduleType != null && aiChatModules.contains(moduleType)));',
        ),
      );

      expect(
        source,
        contains('AppConstants.service'),
      );
    });

    test('AI details route URI-encodes dynamic text', () {
      final String source = File(
        'lib/helper/route_helper.dart',
      ).readAsStringSync();

      expect(
        source,
        contains("Uri.encodeComponent(title ?? '')"),
      );

      expect(
        source,
        contains("Uri.encodeComponent(initialMessage ?? '')"),
      );
    });

    test('customer V4.2 AI endpoint remains authoritative', () {
      final String source = File(
        'lib/util/app_constants.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          "static const String aiChatSendMessageUri = "
          "'/api/v1/customer/ai-chat/send';",
        ),
      );

      expect(
        source,
        isNot(
          contains(
            "static const String aiChatSendMessageUri = "
            "'/api/v1/ai-chat/send';",
          ),
        ),
      );
    });

    test('legacy parallel AI sheet is not reintroduced', () {
      expect(
        File(
          'lib/features/ai_chat/screens/ai_chat_screen.dart',
        ).existsSync(),
        isFalse,
      );

      expect(
        File(
          'lib/features/ai_chat/widgets/ai_chat_floating_button.dart',
        ).existsSync(),
        isFalse,
      );

      expect(
        File(
          'lib/features/ai_chat/widgets/ai_chat_result_sections.dart',
        ).existsSync(),
        isFalse,
      );

      expect(
        File(
          'lib/features/ai_chat/widgets/ai_chat_visuals.dart',
        ).existsSync(),
        isFalse,
      );
    });
  });
}
