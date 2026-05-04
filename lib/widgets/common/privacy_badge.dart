import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({super.key, required this.label, this.internet = false});
  final String label;
  final bool internet;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: internet
              ? AppColors.accent.withOpacity(.15)
              : AppColors.success.withOpacity(.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              internet ? Icons.public : Icons.lock_outline,
              size: 16,
              color: internet ? AppColors.accent : AppColors.success,
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
