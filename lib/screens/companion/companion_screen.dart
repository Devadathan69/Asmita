import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Timer? _stuckTimer;
  bool _showStuckRecovery = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showMemoryNote());
  }

  Future<void> _showMemoryNote() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sakhi_memory_note_seen') == true || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sakhi memory stays here'),
        content: const Text(
          'Sakhi can remember small things you choose to share, like your language preference or what helps you feel better. This memory stays only on this phone. You can delete it anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
    await prefs.setBool('sakhi_memory_note_seen', true);
  }

  @override
  void dispose() {
    _stuckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final ai = ref.watch(aiServiceProvider);
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    final isGenerating = ref.watch(sakhiGeneratingProvider);
    _syncStuckRecovery(isGenerating);
    return FutureBuilder<bool>(
      key: ValueKey(refresh),
      future: ai
          .hasUsableModel()
          .timeout(const Duration(seconds: 3), onTimeout: () => false),
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
              if (!mounted) return;
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
                      subtitle: 'Private companion - No data sent',
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (value) {
                          if (value == 'memory') _showMemorySheet();
                          if (value == 'clear_chat') {
                            ref.read(chatProvider.notifier).clear();
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'memory',
                            child: Text('Memory'),
                          ),
                          PopupMenuItem(
                            value: 'clear_chat',
                            child: Text('Clear chat history'),
                          ),
                        ],
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
                    enabled: !isGenerating,
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
                  if (_showStuckRecovery && isGenerating)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: .92),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              const Expanded(child: Text('Sakhi seems stuck.')),
                              TextButton(
                                onPressed: () {
                                  _stuckTimer?.cancel();
                                  setState(() => _showStuckRecovery = false);
                                  ref
                                      .read(chatProvider.notifier)
                                      .stopCurrentResponse();
                                },
                                child: const Text('Stop'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _syncStuckRecovery(bool isGenerating) {
    if (!isGenerating) {
      _stuckTimer?.cancel();
      _stuckTimer = null;
      if (_showStuckRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showStuckRecovery = false);
        });
      }
      return;
    }
    _stuckTimer ??= Timer(const Duration(seconds: 40), () {
      if (!mounted || !ref.read(sakhiGeneratingProvider)) return;
      setState(() => _showStuckRecovery = true);
    });
  }

  Future<void> _showMemorySheet() async {
    final service = ref.read(aiServiceProvider).memoryService;
    final memories = await service
        .getAllMemories()
        .timeout(const Duration(seconds: 3), onTimeout: () => const []);
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return FutureBuilder(
                future: service.getAllMemories().timeout(
                      const Duration(seconds: 3),
                      onTimeout: () => const [],
                    ),
                initialData: memories,
                builder: (context, snapshot) {
                  final items = snapshot.data ?? const [];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Sakhi Memory',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text(
                          'Saved only on this phone. You can delete it anytime.'),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('No saved memories yet.'),
                        )
                      else
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: items.length,
                            itemBuilder: (_, i) => ListTile(
                              title: Text(items[i].value),
                              subtitle: Text(items[i].category),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await service
                                      .deleteMemory(items[i].key)
                                      .timeout(const Duration(seconds: 3));
                                  if (!context.mounted) return;
                                  setModalState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () async {
                          await service
                              .clearAllMemories()
                              .timeout(const Duration(seconds: 3));
                          if (!context.mounted) return;
                          setModalState(() {});
                        },
                        child: const Text('Clear all memories'),
                      ),
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
              'Talk to Sakhi like a friend',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try: "hi", "I had a bad day", or "remember I like music."',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
