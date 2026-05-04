import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/database_helper.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';
import 'widgets/asha_bridge_widget.dart';
import 'widgets/data_export_widget.dart';
import 'widgets/discreet_mode_widget.dart';
import 'widgets/security_settings_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
            children: [
              const AsmitaScreenHeader(
                title: 'More',
                subtitle: 'Settings, privacy, and local data',
              ),
              const SizedBox(height: 18),
              AsmitaCard(
                accent: AppColors.primary,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryPale,
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Cycle settings: ${profile?.avgCycleLength ?? 28} day cycle, ${profile?.periodDuration ?? 5} day period',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const DiscreetModeWidget(),
              const SizedBox(height: 12),
              const SecuritySettingsWidget(),
              const SizedBox(height: 12),
              const AshaBridgeWidget(),
              const SizedBox(height: 12),
              const DataExportWidget(),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () async => SecurityService.instance.wipeAllData(
                  await DatabaseHelper.instance.database,
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete all data'),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Made with love for Indian women | Team Naayattu, MACE',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
