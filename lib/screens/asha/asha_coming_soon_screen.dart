import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/asmita_button.dart';

class AshaComingSoonScreen extends StatelessWidget {
  const AshaComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.health_and_safety_outlined, size: 96),
              const SizedBox(height: 20),
              Text(
                'ASHA Worker Mode',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Coming Soon', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              AsmitaButton(
                label: 'Back to Asmita',
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
