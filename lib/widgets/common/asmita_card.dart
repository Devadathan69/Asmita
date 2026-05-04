import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

class AsmitaCard extends StatelessWidget {
  const AsmitaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accent,
  });
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: radius,
        border: Border.all(
          color: (accent ?? AppColors.primary).withOpacity(.08),
        ),
        boxShadow: [
          BoxShadow(
            color: (accent ?? AppColors.primary).withOpacity(.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
    return onTap == null
        ? card
        : InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: card,
          ).animate().scale(
              begin: const Offset(.99, .99),
              end: const Offset(1, 1),
              duration: 180.ms,
            );
  }
}
