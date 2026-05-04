import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/music_provider.dart';
import '../../../widgets/common/asmita_card.dart';

class MusicMiniPlayer extends ConsumerWidget {
  const MusicMiniPlayer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(musicServiceProvider);
    final track = service.currentTrack;
    if (track == null) return const SizedBox.shrink();
    return AsmitaCard(
      child: Row(
        children: [
          Expanded(child: Text(track.title)),
          IconButton(onPressed: service.pause, icon: const Icon(Icons.pause)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}
