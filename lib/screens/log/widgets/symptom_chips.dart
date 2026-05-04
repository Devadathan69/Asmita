import 'package:flutter/material.dart';

class SymptomChips extends StatelessWidget {
  const SymptomChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final Set<String> selected;
  final VoidCallback onChanged;
  static const symptoms = [
    'Cramps',
    'Bloating',
    'Headache',
    'Back pain',
    'Cravings',
    'Low mood',
    'Acne',
  ];
  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        children: symptoms
            .map(
              (s) => FilterChip(
                label: Text(s),
                selected: selected.contains(s),
                onSelected: (_) {
                  selected.contains(s) ? selected.remove(s) : selected.add(s);
                  onChanged();
                },
              ),
            )
            .toList(),
      );
}
