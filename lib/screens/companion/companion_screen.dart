import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/strings.dart';
import '../../providers/ai_companion_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/privacy_badge.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/companion_input_bar.dart';
import 'widgets/model_loading_indicator.dart';

class CompanionScreen extends ConsumerStatefulWidget {
  const CompanionScreen({super.key});

  @override
  ConsumerState<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends ConsumerState<CompanionScreen> {
  int refresh = 0;

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final ai = ref.watch(aiServiceProvider);
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    return FutureBuilder<bool>(
      key: ValueKey(refresh),
      future: ai.isModelAvailable(),
      builder: (context, model) {
        if (model.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (model.data != true) {
          return ModelLoadingIndicator(
            onDownload: ai.downloadModel,
            onComplete: () {
              setState(() => refresh++);
              ref.invalidate(chatProvider);
            },
          );
        }
        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: AsmitaScreenHeader(
                      title: 'Sakhi',
                      subtitle: 'Private companion • No data sent',
                      trailing: IconButton.filledTonal(
                        onPressed: () =>
                            ref.read(chatProvider.notifier).clear(),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: PrivacyBadge(label: 'Running on your device'),
                    ),
                  ),
                  Expanded(
                    child: chat.when(
                      data: (messages) => messages.isEmpty
                          ? const _EmptySakhiState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              itemBuilder: (_, i) =>
                                  ChatBubble(message: messages[i]),
                            ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('$e')),
                    ),
                  ),
                  CompanionInputBar(
                    onSend: (text) {
                      if (text.length <= 500) {
                        ref.read(chatProvider.notifier).send(
                              text,
                              language: language.name,
                            );
                      }
                    },
                    onMic: () => HapticFeedback.selectionClick(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptySakhiState extends StatelessWidget {
  const _EmptySakhiState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 58,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'Ask Sakhi anything gently',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try: "What should I eat today?" or "My cramps are bad."',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
