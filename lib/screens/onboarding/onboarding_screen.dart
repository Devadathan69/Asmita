import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/privacy_badge.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Private by design', 'Your cycle notes stay on this device.'),
      ('Gentle insights', 'Asmita talks about cycle patterns without alarm.'),
      (
        'Made for India',
        'Languages, food tips, and care options that feel familiar.',
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PrivacyBadge(label: 'No data sent'),
              const SizedBox(height: 24),
              Text(
                'Welcome to Asmita',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              ...items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(item.$1),
                  subtitle: Text(item.$2),
                ),
              ),
              const Spacer(),
              AsmitaButton(
                label: 'Set up privately',
                onPressed: () => context.go('/setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
