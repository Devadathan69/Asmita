import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class RotatingFlowerDisc extends StatefulWidget {
  const RotatingFlowerDisc({
    super.key,
    required this.isPlaying,
    required this.color,
    this.size = 184,
  });

  final bool isPlaying;
  final Color color;
  final double size;

  @override
  State<RotatingFlowerDisc> createState() => _RotatingFlowerDiscState();
}

class _RotatingFlowerDiscState extends State<RotatingFlowerDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant RotatingFlowerDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) _sync();
  }

  void _sync() {
    if (widget.isPlaying) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).accessibleNavigation;
    if (reduceMotion && _controller.isAnimating) _controller.stop();
    return RepaintBoundary(
      child: RotationTransition(
        turns: reduceMotion ? const AlwaysStoppedAnimation(0) : _controller,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _FlowerDiscPainter(
            color: widget.color,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class _FlowerDiscPainter extends CustomPainter {
  const _FlowerDiscPainter({
    required this.color,
    required this.isDark,
  });

  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final base = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(isDark ? .42 : .24),
          (isDark ? AppColors.darkCard : Colors.white).withOpacity(.96),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(center, radius, base);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withOpacity(.22);
    for (final fraction in [.34, .52, .72, .9]) {
      canvas.drawCircle(center, radius * fraction, ring);
    }

    final petalPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(.18);
    for (var i = 0; i < 16; i++) {
      final angle = (math.pi * 2 / 16) * i;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final rect = Rect.fromCenter(
        center: Offset(radius * .42, 0),
        width: radius * .56,
        height: radius * .2,
      );
      canvas.drawOval(rect, petalPaint);
      canvas.restore();
    }

    final dot = Paint()..color = color;
    canvas.drawCircle(center, radius * .13, dot);
    canvas.drawCircle(
      center,
      radius * .055,
      Paint()..color = isDark ? AppColors.darkBackground : Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _FlowerDiscPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isDark != isDark;
}
