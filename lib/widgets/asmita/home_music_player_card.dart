import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../l10n/strings.dart';
import '../../providers/language_provider.dart';
import '../../providers/music_provider.dart';
import '../../services/music_service.dart';
import '../../theme/app_colors.dart';
import '../common/asmita_card.dart';
import 'phase_music_player_sheet.dart';
import 'rotating_flower_disc.dart';

class HomeMusicPlayerCard extends ConsumerStatefulWidget {
  const HomeMusicPlayerCard({super.key});

  @override
  ConsumerState<HomeMusicPlayerCard> createState() =>
      _HomeMusicPlayerCardState();
}

class _HomeMusicPlayerCardState extends ConsumerState<HomeMusicPlayerCard> {
  bool _isSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(musicServiceProvider);
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    String t(String key) => Strings.t(key, language);

    return StreamBuilder<PlayerState>(
      stream: service.playerState,
      builder: (context, playerSnapshot) {
        final state = playerSnapshot.data;
        final active = service.currentTrack != null &&
            state?.processingState != ProcessingState.idle;
        if (!active) return const SizedBox.shrink();

        return StreamBuilder<int?>(
          stream: service.currentIndex,
          builder: (context, _) {
            final track = service.currentTrack;
            if (track == null) return const SizedBox.shrink();
            final isPlaying = state?.playing ?? service.isPlaying;
            return AsmitaCard(
              accent: track.phase.color,
              onTap: () => _openSheet(track),
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  RotatingFlowerDisc(
                    isPlaying: isPlaying,
                    color: track.phase.color,
                    size: 68,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('now_playing'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${track.phase.label} · ${t('open_player')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        _MiniProgress(
                            service: service, color: track.phase.color),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isPlaying ? t('pause') : t('play'),
                    onPressed: () =>
                        isPlaying ? service.pause() : service.play(),
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: track.phase.color,
                      size: 34,
                    ),
                  ),
                  IconButton(
                    tooltip: t('next'),
                    onPressed: service.next,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                  IconButton(
                    tooltip: t('stop'),
                    onPressed: service.stop,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openSheet(TrackInfo track) async {
    if (_isSheetOpen) return;
    _isSheetOpen = true;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PhaseMusicPlayerSheet(initialTrack: track),
      );
    } finally {
      _isSheetOpen = false;
    }
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.service, required this.color});

  final MusicService service;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: service.duration,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data;
        return StreamBuilder<Duration>(
          stream: service.position,
          builder: (context, positionSnapshot) {
            final max = duration?.inMilliseconds ?? 0;
            final value = positionSnapshot.data?.inMilliseconds ?? 0;
            final progress = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: progress,
                color: color,
                backgroundColor: AppColors.lilacMist,
              ),
            );
          },
        );
      },
    );
  }
}
