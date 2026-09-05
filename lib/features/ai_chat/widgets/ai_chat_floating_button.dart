import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_visuals.dart';

class AiChatFloatingButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? heroTag;
  const AiChatFloatingButton({super.key, required this.onTap, this.heroTag});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(7),
    child: FloatingActionButton(
      heroTag: heroTag ?? 'customer-ai-chat',
      tooltip: 'AI_Chat_Assistant'.tr,
      onPressed: onTap,
      elevation: 4,
      highlightElevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const AiChatMark(size: 56),
    ),
  );
}
