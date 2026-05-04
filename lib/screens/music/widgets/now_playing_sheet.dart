import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/music_provider.dart';
import '../../../widgets/common/privacy_badge.dart';

class NowPlayingSheet extends ConsumerWidget {
  const NowPlayingSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(musicServiceProvider);
    final track = service.currentTrack;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PrivacyBadge(label: 'No streaming'),
          const SizedBox(height: 16),
          Text(
            track?.title ?? 'Ready',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          StreamBuilder<Duration>(
            stream: service.position,
            builder: (context, snapshot) => Slider(
              value: (snapshot.data ?? Duration.zero).inSeconds.toDouble(),
              max: 240,
              onChanged: (v) => service.seek(Duration(seconds: v.round())),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: service.previous,
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: service.pause,
                icon: const Icon(Icons.pause_circle, size: 44),
              ),
              IconButton(
                onPressed: service.next,
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
          SwitchListTile(
            value: false,
            onChanged: service.setLoop,
            title: const Text('Loop'),
          ),
          Slider(value: 1, onChanged: service.setVolume),
          const Text('This music is stored on your device - no streaming'),
        ],
      ),
    );
  }
}
