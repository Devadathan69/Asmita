import 'package:flutter/material.dart';
import '../../../l10n/strings.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/asmita_card.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.phase,
    required this.language,
    required this.count,
    required this.onTap,
  });
  final CyclePhase phase;
  final AppLanguage language;
  final int count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    String t(String key) => Strings.t(key, language);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AsmitaCard(
        accent: phase.color,
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
                '${phase.label} ${t('playlist')}\n$count ${t('tracks')}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}
