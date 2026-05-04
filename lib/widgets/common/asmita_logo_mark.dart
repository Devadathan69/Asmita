import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AsmitaLogoMark extends StatelessWidget {
  const AsmitaLogoMark({
    super.key,
    this.size = 72,
    this.heroTag,
    this.showGlow = true,
  });

  final double size;
  final String? heroTag;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final image = ClipOval(
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
    final mark = Container(
      padding: EdgeInsets.all(size * .08),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.22),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: image,
    ).animate().fadeIn(duration: 420.ms).scale(
          begin: const Offset(.88, .88),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );

    return heroTag == null ? mark : Hero(tag: heroTag!, child: mark);
  }
}
