import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.showBottomNav = true,
    this.padding = const EdgeInsets.fromLTRB(24, 18, 24, 100),
  });

  final Widget child;
  final int currentIndex;
  final bool showBottomNav;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _GlowBackground(),
          SafeArea(
            child: SingleChildScrollView(padding: padding, child: child),
          ),
          if (showBottomNav)
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: AppBottomNav(currentIndex: currentIndex),
            ),
        ],
      ),
    );
  }
}

class _GlowBackground extends StatelessWidget {
  const _GlowBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-1.25, -0.9),
          radius: 0.9,
          colors: [Color(0x663B1708), AppColors.background],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x00101010), Color(0xAA080808)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
