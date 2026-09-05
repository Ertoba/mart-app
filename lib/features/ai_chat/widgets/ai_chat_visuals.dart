import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Duration aiChatDuration(BuildContext context, [int milliseconds = 220]) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: milliseconds);

Color aiChatBorder(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF39434F)
    : const Color(0xFFE1E7EC);

Color aiChatMuted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFB8C4CE)
    : const Color(0xFF596A75);

class AiChatMark extends StatelessWidget {
  final double size;
  const AiChatMark({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor,
              Color.lerp(theme.primaryColor, const Color(0xFF6454C0), .55)!,
            ],
          ),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: size * .5,
        ),
      ),
    );
  }
}

class AiChatTypingIndicator extends StatefulWidget {
  const AiChatTypingIndicator({super.key});
  @override
  State<AiChatTypingIndicator> createState() => _AiChatTypingIndicatorState();
}

class _AiChatTypingIndicatorState extends State<AiChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = .5;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      label: 'ai_chat_typing'.tr,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const AiChatMark(size: 30),
              const SizedBox(width: 10),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final wave =
                        (math.sin(
                              (_controller.value - index * .16) * math.pi * 2,
                            ) +
                            1) /
                        2;
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 4),
                      child: Opacity(
                        opacity: .35 + .65 * wave,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'ai_chat_typing'.tr,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
