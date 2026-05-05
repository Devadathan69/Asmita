import 'package:flutter/material.dart';

class PhaseInstructionCard extends StatelessWidget {
  const PhaseInstructionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.instructions,
    required this.color,
  });

  final IconData icon;
  final String title;
  final List<String> instructions;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 54),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final line in instructions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $line'),
            ),
        ],
      ),
    );
  }
}
