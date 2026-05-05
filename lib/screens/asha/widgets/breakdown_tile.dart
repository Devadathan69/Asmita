import 'package:flutter/material.dart';

class BreakdownTile extends StatelessWidget {
  const BreakdownTile({
    super.key,
    required this.label,
    required this.value,
    required this.max,
  });

  final String label;
  final double value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            '${value.toStringAsFixed(1)}/$max pts',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
