import 'package:flutter/material.dart';
import '../../../services/security_service.dart';
import '../../../widgets/common/asmita_card.dart';

class SecuritySettingsWidget extends StatefulWidget {
  const SecuritySettingsWidget({super.key});
  @override
  State<SecuritySettingsWidget> createState() => _SecuritySettingsWidgetState();
}

class _SecuritySettingsWidgetState extends State<SecuritySettingsWidget> {
  final pin = TextEditingController();
  @override
  Widget build(BuildContext context) => AsmitaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: pin,
              maxLength: 4,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Discreet PIN'),
            ),
            FilledButton(
              onPressed: () async {
                if (pin.text.length == 4)
                  await SecurityService.instance.setPin(pin.text);
              },
              child: const Text('Save PIN'),
            ),
          ],
        ),
      );
}
