import 'package:flutter/material.dart';

class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      avatar: icon == null ? null : Icon(icon, size: 18),
      label: Text(label),
      showCheckmark: false,
    );
  }
}
