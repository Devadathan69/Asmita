import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/screening_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/privacy_badge.dart';

class AshaHomeScreen extends ConsumerWidget {
  const AshaHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: FutureBuilder(
            future: ScreeningStorageService().getHistory(),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/mode'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ASHA Screening',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const Text(
                                'Project Asmita — Adolescent Health Screening'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ready to screen',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, dd MMM yyyy')
                              .format(DateTime.now()),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$count screenings saved',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AsmitaButton(
                    label: 'Start New Screening',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => context.go('/asha/instructions'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/asha/history'),
                    icon: const Icon(Icons.history),
                    label: const Text('View History'),
                  ),
                  const SizedBox(height: 20),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      PrivacyBadge(label: 'Fully Offline'),
                      PrivacyBadge(label: 'No Blood Test'),
                      PrivacyBadge(label: '2 Minutes'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const AsmitaCard(
                    child: Text(
                      'No personal data stored. All records anonymized.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
