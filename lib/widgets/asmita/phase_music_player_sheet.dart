import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../l10n/strings.dart';
import '../../providers/language_provider.dart';
import '../../providers/music_provider.dart';
import '../../services/music_service.dart';
import '../../theme/app_colors.dart';
import '../common/privacy_badge.dart';
import 'rotating_flower_disc.dart';

class PhaseMusicPlayerSheet extends ConsumerStatefulWidget {
  const PhaseMusicPlayerSheet({
    super.key,
    required this.initialTrack,
  });

  final TrackInfo initialTrack;

  @override
  ConsumerState<PhaseMusicPlayerSheet> createState() =>
      _PhaseMusicPlayerSheetState();
}

class _PhaseMusicPlayerSheetState extends ConsumerState<PhaseMusicPlayerSheet> {
  double _volume = .7;
  String? _error;

  @override
  void initState() {
    super.initState();
    _volume = ref.read(musicServiceProvider).currentVolume;
    if (_volume == 0) _volume = .7;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(musicServiceProvider);
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    String t(String key) => Strings.t(key, language);
    final phase = widget.initialTrack.phase;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            MediaQuery.of(context).padding.bottom + 18,
          ),
          child: StreamBuilder<PlayerState>(
            stream: service.playerState,
            builder: (context, stateSnapshot) {
              final playerState = stateSnapshot.data;
              final isPlaying = playerState?.playing ?? service.isPlaying;
              return StreamBuilder<int?>(
                stream: service.currentIndex,
                builder: (context, _) {
                  final track = service.currentTrack ?? widget.initialTrack;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(.35),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      Row(
                        children: [
                          PrivacyBadge(label: t('no_streaming')),
                          const Spacer(),
                          IconButton(
                            tooltip: t('cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t('now_playing'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${phase.label} · ${t('calm_audio')}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 22),
                      RotatingFlowerDisc(
                        isPlaying: isPlaying,
                        color: phase.color,
                      ),
                      const SizedBox(height: 18),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _ProgressBar(service: service),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _RoundControl(
                            tooltip: t('previous'),
                            icon: Icons.skip_previous_rounded,
                            onPressed: () => _guard(service.previous, t),
                          ),
                          const SizedBox(width: 18),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              shape: const CircleBorder(),
                              minimumSize: const Size.square(66),
                              backgroundColor: phase.color,
                            ),
                            onPressed: () => _guard(
                              isPlaying ? service.pause : service.play,
                              t,
                            ),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 18),
                          _RoundControl(
                            tooltip: t('next'),
                            icon: Icons.skip_next_rounded,
                            onPressed: () => _guard(service.next, t),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.volume_down_rounded),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              min: 0,
                              max: 1,
                              activeColor: phase.color,
                              onChanged: (value) {
                                setState(() => _volume = value);
                                service.setVolume(value);
                              },
                            ),
                          ),
                          const Icon(Icons.volume_up_rounded),
                        ],
                      ),
                      Text(t('volume')),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _guard(
    Future<void> Function() action,
    String Function(String) t,
  ) async {
    try {
      setState(() => _error = null);
      await action();
    } catch (_) {
      if (mounted) setState(() => _error = t('unable_to_play_track'));
    }
  }
}

class _ProgressBar extends StatefulWidget {
  const _ProgressBar({required this.service});
  final MusicService service;

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: widget.service.duration,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: widget.service.position,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final max = duration.inMilliseconds <= 0
                ? 1.0
                : duration.inMilliseconds.toDouble();
            final value = (_dragValue ?? position.inMilliseconds.toDouble())
                .clamp(0.0, max);
            return Column(
              children: [
                Slider(
                  value: value,
                  max: max,
                  onChanged: (next) => setState(() => _dragValue = next),
                  onChangeEnd: (next) async {
                    setState(() => _dragValue = null);
                    await widget.service.seek(
                      Duration(milliseconds: next.round()),
                    );
                  },
                ),
                Row(
                  children: [
                    Text(_format(position)),
                    const Spacer(),
                    Text(_format(duration)),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      iconSize: 30,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
