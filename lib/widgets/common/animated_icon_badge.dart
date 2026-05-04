import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedIconBadge extends StatelessWidget {
  const AnimatedIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 58,
    this.background,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? color.withOpacity(.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * .42),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.06, 1.06),
          duration: 1400.ms,
          curve: Curves.easeInOut,
        );
  }
}
