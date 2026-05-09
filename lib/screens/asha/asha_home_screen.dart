import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ASHA Screening',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const Text(
                                'Project Asmita - Adolescent Health Screening'),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (value) {
                          if (value == 'personal') context.go('/home');
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'personal',
                            child: Text('Switch to Personal Tracking'),
                          ),
                        ],
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
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ).animate().scale(duration: 420.ms),
                        const SizedBox(width: 16),
                        Expanded(
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
                              const SizedBox(height: 6),
                              Text(
                                DateFormat('dd MMM yyyy')
                                    .format(DateTime.now()),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
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
                      ],
                    ),
                  ).animate().fadeIn(duration: 360.ms).slideY(begin: .04),
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
