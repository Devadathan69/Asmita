import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/asmita_card.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.phase,
    required this.count,
    required this.onTap,
  });
  final CyclePhase phase;
  final int count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AsmitaCard(
          onTap: onTap,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: phase.color,
                child: const Icon(Icons.music_note, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${phase.label} playlist\n$count tracks',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Icon(Icons.play_arrow),
            ],
          ),
        ),
      );
}
