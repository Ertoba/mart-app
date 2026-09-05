import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/ai_chat/screens/ai_chat_screen.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_floating_button.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_visuals.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    Get.put<SharedPreferences>(await SharedPreferences.getInstance());
    Get.addTranslations({
      for (final locale in ['en', 'ka', 'ru'])
        locale: Map<String, String>.from(
          jsonDecode(File('assets/language/$locale.json').readAsStringSync())
              as Map,
        ),
    });
  });
  tearDown(() => Get.reset());

  for (final locale in ['en', 'ka', 'ru']) {
    testWidgets(
      '$locale composer and header fit a narrow screen with large text',
      (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          GetMaterialApp(
            locale: Locale(locale),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.6),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: const Scaffold(body: AiChatSheet()),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final send = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == 'send'.tr,
        );
        expect(tester.widget<IconButton>(send).onPressed, isNull);
        await tester.enterText(find.byType(TextField), '   ');
        await tester.pump();
        expect(tester.widget<IconButton>(send).onPressed, isNull);
        await tester.enterText(
          find.byType(TextField),
          'ერთი პროდუქტის შესახებ კითხვა',
        );
        await tester.pump();
        expect(tester.widget<IconButton>(send).onPressed, isNotNull);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('new_chat'.tr).first);
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty,
        );
        // Simulate the shorter space available above the on-screen keyboard.
        tester.view.physicalSize = const Size(360, 420);
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('chat_history'.tr));
        await tester.pumpAndSettle();
        expect(find.text('no_chat_history'.tr), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'reduced motion stops the waiting animation and still explains the state',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: AiChatTypingIndicator()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AiChatTypingIndicator), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('assistant launcher supports keyboard activation', (
    tester,
  ) async {
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: AiChatFloatingButton(onTap: () => opened++),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(opened, 1);
  });
}
