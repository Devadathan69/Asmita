import 'package:flutter/material.dart';

class SymptomChips extends StatelessWidget {
  const SymptomChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.options = symptoms,
  });
  final Set<String> selected;
  final VoidCallback onChanged;
  final List<String> options;
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
        runSpacing: 8,
        children: options
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
