import 'package:flutter/material.dart';
import '../../../widgets/common/asmita_card.dart';

class DiscreetModeWidget extends StatefulWidget {
  const DiscreetModeWidget({super.key});
  @override
  State<DiscreetModeWidget> createState() => _DiscreetModeWidgetState();
}

class _DiscreetModeWidgetState extends State<DiscreetModeWidget> {
  bool enabled = false;
  @override
  Widget build(BuildContext context) => AsmitaCard(
        child: SwitchListTile(
          value: enabled,
          onChanged: (v) => setState(() => enabled = v),
          title: const Text('Discreet mode'),
          subtitle: const Text('Shows Health Notes and asks for PIN first.'),
        ),
      );
}
