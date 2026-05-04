import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PainBodyMap extends StatelessWidget {
  const PainBodyMap({
    super.key,
    required this.selectedZones,
    required this.onChanged,
  });
  final Set<String> selectedZones;
  final VoidCallback onChanged;
  static const zones = [
    'head',
    'chest',
    'lower abdomen',
    'lower back',
    'upper back',
    'left leg',
    'right leg',
    'shoulders',
  ];
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pain map', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            height: 260,
            child: CustomPaint(
              painter: _BodyPainter(selectedZones),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 4,
                children: zones
                    .map(
                      (z) => TextButton(
                        onPressed: () {
                          selectedZones.contains(z)
                              ? selectedZones.remove(z)
                              : selectedZones.add(z);
                          onChanged();
                        },
                        child: Text(z),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      );
}

class _BodyPainter extends CustomPainter {
  _BodyPainter(this.zones);
  final Set<String> zones;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withOpacity(.12);
    final active = Paint()..color = AppColors.secondary.withOpacity(.35);
    final c = Offset(size.width / 2, 38);
    canvas.drawCircle(c, 22, zones.contains('head') ? active : paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, 120),
          width: 86,
          height: 118,
        ),
        const Radius.circular(42),
      ),
      zones.intersection({
        'chest',
        'lower abdomen',
        'upper back',
        'lower back',
        'shoulders',
      }).isNotEmpty
          ? active
          : paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 48, 178, 36, 74),
        const Radius.circular(18),
      ),
      zones.contains('left leg') ? active : paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 + 12, 178, 36, 74),
        const Radius.circular(18),
      ),
      zones.contains('right leg') ? active : paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) =>
      oldDelegate.zones != zones;
}
