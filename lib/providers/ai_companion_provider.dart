import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/models/chat_message.dart';
import '../services/sakhi_ai_service.dart';
import '../services/sakhi_memory_service.dart';

final sakhiAiServiceProvider = Provider<SakhiAiService>((ref) {
  final service = SakhiAiService();
  ref.onDispose(service.dispose);
  return service;
});

final aiServiceProvider = sakhiAiServiceProvider;

final sakhiGeneratingProvider = StateProvider<bool>((ref) => false);

final chatProvider = AsyncNotifierProvider<ChatNotifier, List<ChatMessage>>(
  ChatNotifier.new,
);

class ChatNotifier extends AsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() async {
    final messages = await ref
        .read(sakhiAiServiceProvider)
        .memoryService
        .getRecentChatMessages(limit: 60);
    return messages.map(_toChatMessage).toList();
  }

  Future<void> send(String text, {required String language}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || ref.read(sakhiGeneratingProvider)) return;

    ref.read(sakhiGeneratingProvider.notifier).state = true;
    final now = DateTime.now();
    final user = ChatMessage(
      content: trimmed,
      role: 'user',
      timestamp: now,
      sessionId: 'sakhi_local_memory',
    );
    final thinking = ChatMessage(
      content: 'Sakhi is thinking...',
      role: 'assistant',
      timestamp: now,
      sessionId: 'sakhi_local_memory',
    );
    state = AsyncData([...state.value ?? [], user, thinking]);

    try {
      final history = (state.value ?? const [])
          .where((message) => message.content != thinking.content)
          .map((message) => SakhiChatMessage(
                role: message.role,
                content: message.content,
                timestamp: message.timestamp,
              ))
          .toList();
      final reply = await ref
          .read(sakhiAiServiceProvider)
          .generateReply(
            history: history,
            userMessage: trimmed,
            languageCode: language,
          )
          .timeout(const Duration(seconds: 75));
      final visible = (state.value ?? const [])
          .where((message) => message.content != thinking.content)
          .toList();
      state = AsyncData([
        ...visible,
        ChatMessage(
          content: reply,
          role: 'assistant',
          timestamp: DateTime.now(),
          sessionId: 'sakhi_local_memory',
        ),
      ]);
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('Sakhi UI timeout: $error\n$stackTrace');
      _replaceThinkingWithError(thinking);
    } catch (error, stackTrace) {
      debugPrint('Sakhi send failed: $error\n$stackTrace');
      _replaceThinkingWithError(thinking);
    } finally {
      ref.read(sakhiGeneratingProvider.notifier).state = false;
    }
  }

  Future<void> clear() async {
    await ref.read(sakhiAiServiceProvider).memoryService.clearChatHistory();
    state = const AsyncData([]);
  }

  ChatMessage _toChatMessage(SakhiChatMessage message) {
    return ChatMessage(
      content: message.content,
      role: message.role,
      timestamp: message.timestamp,
      sessionId: 'sakhi_local_memory',
    );
  }

  void _replaceThinkingWithError(ChatMessage thinking) {
    final visible = (state.value ?? const [])
        .where((message) => message.content != thinking.content)
        .toList();
    state = AsyncData([
      ...visible,
      ChatMessage(
        content: "I'm having trouble thinking right now. Please try again.",
        role: 'assistant',
        timestamp: DateTime.now(),
        sessionId: 'sakhi_local_memory',
      ),
    ]);
  }
}
