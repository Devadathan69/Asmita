import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/music_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/privacy_badge.dart';
import 'widgets/now_playing_sheet.dart';
import 'widgets/playlist_card.dart';

class MusicScreen extends ConsumerWidget {
  const MusicScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(musicServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Music for your cycle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PrivacyBadge(label: 'Stored on your device'),
          const SizedBox(height: 16),
          for (final phase in CyclePhase.values)
            PlaylistCard(
              phase: phase,
              count: service.tracksFor(phase).length,
              onTap: () async {
                await service.loadPlaylist(phase);
                await service.play();
                if (context.mounted)
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const NowPlayingSheet(),
                  );
              },
            ),
        ],
      ),
    );
  }
}
