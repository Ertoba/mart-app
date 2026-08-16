import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiChatFloatingButton extends StatefulWidget {
  final VoidCallback onTap;
  final String? heroTag;

  const AiChatFloatingButton({super.key, required this.onTap, this.heroTag});

  @override
  State<AiChatFloatingButton> createState() => _AiChatFloatingButtonState();
}

class _AiChatFloatingButtonState extends State<AiChatFloatingButton>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pressController;
  late final AnimationController _sparkleController;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceFade;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _entranceScale = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _pressScale = Tween<double>(
      begin: 1,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pressController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    const Color accent = Color(0xFF8E5BFF);

    return Tooltip(
      message: 'AI_Chat_Assistant'.tr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressController.forward(),
        onTapCancel: () => _pressController.reverse(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_entranceController, _pressController]),
          builder: (context, child) => Opacity(
            opacity: _entranceFade.value,
            child: Transform.scale(
              scale: _entranceScale.value * _pressScale.value,
              child: child,
            ),
          ),
          child: Hero(
            tag: widget.heroTag ?? 'customer-ai-chat',
            child: SizedBox(
              width: 66,
              height: 66,
              child: Center(
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: accent.withValues(alpha: 0.22),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _sparkleController,
                    builder: (context, _) => CustomPaint(
                      painter: _SparklePainter(value: _sparkleController.value),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double value;

  const _SparklePainter({required this.value});

  static const List<(Offset, double, double)> _sparkles = [
    (Offset(0.50, 0.52), 0.30, 0),
    (Offset(0.80, 0.22), 0.13, 0.35),
    (Offset(0.24, 0.78), 0.10, 0.70),
  ];

  Path _path(double radius) {
    final double inner = radius * 0.18;
    return Path()
      ..moveTo(0, -radius)
      ..quadraticBezierTo(inner, -inner, radius, 0)
      ..quadraticBezierTo(inner, inner, 0, radius)
      ..quadraticBezierTo(-inner, inner, -radius, 0)
      ..quadraticBezierTo(-inner, -inner, 0, -radius)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    for (final (Offset position, double factor, double offset) in _sparkles) {
      final double phase = (value + offset) % 1;
      final double wave = (math.sin(phase * 2 * math.pi) + 1) / 2;
      final double radius = factor * size.width * (0.65 + 0.6 * wave);
      paint.color = Colors.white.withValues(alpha: 0.55 + 0.45 * wave);
      canvas.save();
      canvas.translate(position.dx * size.width, position.dy * size.height);
      canvas.rotate(phase * 2 * math.pi);
      canvas.drawPath(_path(radius), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
