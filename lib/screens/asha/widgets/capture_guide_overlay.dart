import 'package:flutter/material.dart';

class CaptureGuideOverlay extends StatelessWidget {
  const CaptureGuideOverlay({
    super.key,
    required this.step,
    this.tooDark = false,
  });

  final String step;
  final bool tooDark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          _GuidePainter(step: step, color: tooDark ? Colors.red : Colors.white),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 210),
          child: Text(
            switch (step) {
              'neck' => 'Align neck here',
              'knuckle' => 'Align knuckles here',
              _ => 'Align face here',
            },
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              shadows: [Shadow(blurRadius: 8)],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter({required this.step, required this.color});

  final String step;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final center = size.center(Offset.zero);
    if (step == 'knuckle') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: size.width * .72, height: 170),
          const Radius.circular(26),
        ),
        paint,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: step == 'face' ? size.width * .62 : size.width * .72,
          height: step == 'face' ? 280 : 190,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePainter oldDelegate) =>
      oldDelegate.step != step || oldDelegate.color != color;
}
