import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [
                      AppColors.darkBackground,
                      Color(0xFF24113D),
                    ]
                  : const [
                      Color(0xFFFFF8FA),
                      AppColors.secondaryPale,
                      Colors.white,
                    ],
            ),
          ),
        ),
        const Positioned(
          top: 90,
          right: -42,
          child: _Facet(size: 150, color: AppColors.primaryPale),
        ),
        const Positioned(
          bottom: 120,
          left: -52,
          child: _Facet(size: 180, color: AppColors.coralPale),
        ),
        child,
      ],
    );
  }
}

class _Facet extends StatelessWidget {
  const _Facet({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: .78,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(.62),
          borderRadius: BorderRadius.circular(38),
        ),
      ),
    );
  }
}
