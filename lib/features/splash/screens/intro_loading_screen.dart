import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/splash_route_helper.dart';
import 'package:sixam_mart/util/images.dart';

class IntroLoadingScreen extends StatefulWidget {
  final NotificationBodyModel? body;

  const IntroLoadingScreen({super.key, required this.body});

  @override
  State<IntroLoadingScreen> createState() => _IntroLoadingScreenState();
}

class _IntroLoadingScreenState extends State<IntroLoadingScreen> {
  Timer? _routeTimer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });
    _routeTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      route(body: widget.body);
    });
  }

  @override
  void dispose() {
    _routeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double animationSize = MediaQuery.sizeOf(
      context,
    ).shortestSide.clamp(180.0, 260.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFF039D55),
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Lottie.asset(
            Images.shoppingCartIntro,
            width: animationSize,
            height: animationSize,
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
      ),
    );
  }
}
