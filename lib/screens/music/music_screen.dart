import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/strings.dart';
import '../../providers/language_provider.dart';
import '../../providers/music_provider.dart';
import '../../services/music_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/asmita/phase_music_player_sheet.dart';
import '../../widgets/common/privacy_badge.dart';
import 'widgets/playlist_card.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  bool _isMusicSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(musicServiceProvider);
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    String t(String key) => Strings.t(key, language);
    return Scaffold(
      appBar: AppBar(title: Text(t('music_for_cycle'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          PrivacyBadge(label: t('stored_on_device')),
          const SizedBox(height: 20),
          for (final phase in CyclePhase.values) ...[
            PlaylistCard(
              phase: phase,
              language: language,
              count: service.tracksFor(phase).length,
              onTap: () async {
                final tracks = service.tracksFor(phase);
                if (tracks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('music_not_added'))),
                  );
                  return;
                }
                try {
                  await service.loadPlaylist(phase, autoplay: true);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('audio_file_not_found'))),
                  );
                  return;
                }
                if (context.mounted) {
                  await _openMusicPlayerSheet(tracks.first);
                }
              },
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Future<void> _openMusicPlayerSheet(TrackInfo track) async {
    if (_isMusicSheetOpen) return;
    _isMusicSheetOpen = true;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PhaseMusicPlayerSheet(initialTrack: track),
      );
    } finally {
      _isMusicSheetOpen = false;
    }
  }
}
