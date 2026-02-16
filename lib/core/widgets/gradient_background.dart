import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0B1220), AppColors.darkBackground]
                  : [const Color(0xFFF1F5FF), AppColors.lightBackground],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _BlurCircle(color: AppColors.royalIndigo.withAlpha(51)),
        ),
        Positioned(
          bottom: -60,
          left: -30,
          child: _BlurCircle(color: AppColors.emerald.withAlpha(41)),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)],
      ),
    );
  }
}
