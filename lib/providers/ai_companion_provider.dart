import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/models/chat_message.dart';
import '../services/sakhi_ai_service.dart';
import '../services/sakhi_memory_service.dart';
import 'user_profile_provider.dart';

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
  int _generationSerial = 0;

  @override
  Future<List<ChatMessage>> build() async {
    final messages = await ref
        .read(sakhiAiServiceProvider)
        .memoryService
        .getRecentChatMessages(limit: 60)
        .timeout(const Duration(seconds: 3), onTimeout: () => const []);
    return messages.map(_toChatMessage).toList();
  }

  Future<void> send(String text, {required String language}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || ref.read(sakhiGeneratingProvider)) return;

    final service = ref.read(sakhiAiServiceProvider);
    debugPrint('[SakhiAI] sendMessage start');
    ref.read(sakhiGeneratingProvider.notifier).state = true;
    final generationId = ++_generationSerial;
    final now = DateTime.now();
    ChatMessage? thinking;

    try {
      final user = ChatMessage(
        content: trimmed,
        role: 'user',
        timestamp: now,
        sessionId: 'sakhi_local_memory',
      );
      state = AsyncData([...state.value ?? [], user]);

      if (!kUseSakhiMockModel) {
        final modelReady = await service
            .hasUsableModel()
            .timeout(const Duration(seconds: 3), onTimeout: () => false);
        debugPrint('[SakhiAI] hasUsableModel: $modelReady');
        if (!modelReady) {
          _appendAssistant(
            "Sakhi's offline AI model is missing or incomplete. Please download it again.",
          );
          return;
        }
      }

      thinking = ChatMessage(
        content: 'Sakhi is thinking...',
        role: 'assistant',
        timestamp: now,
        sessionId: 'sakhi_local_memory',
      );
      state = AsyncData([...state.value ?? [], thinking]);

      final reply = await ref
          .read(sakhiAiServiceProvider)
          .generateReply(
            userMessage: trimmed,
            languageCode: language,
            modeContext: _modeContext(),
          )
          .timeout(const Duration(seconds: 90));
      if (generationId != _generationSerial) return;
      final visible = (state.value ?? const [])
          .where((message) => message.content != thinking?.content)
          .toList();
      state = AsyncData([...visible]);
      _appendAssistant(reply);
      unawaited(service.persistConversationInBackground(trimmed, reply));
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('Sakhi UI timeout: $error\n$stackTrace');
      if (generationId == _generationSerial) {
        _replaceThinkingWithMessage(
          thinking,
          'Sakhi is taking too long to respond. Please try again.',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Sakhi send failed: $error\n$stackTrace');
      if (generationId == _generationSerial) {
        _replaceThinkingWithMessage(
          thinking,
          "I'm having trouble thinking right now. Please try again.",
        );
      }
    } finally {
      if (generationId == _generationSerial) {
        ref.read(sakhiGeneratingProvider.notifier).state = false;
      }
    }
  }

  void stopCurrentResponse() {
    _generationSerial++;
    unawaited(ref.read(sakhiAiServiceProvider).stopGeneration());
    ref.read(sakhiGeneratingProvider.notifier).state = false;
    _replaceThinkingWithMessage(
      null,
      'I stopped that response. Please try again.',
    );
  }

  Future<void> clear() async {
    await ref
        .read(sakhiAiServiceProvider)
        .memoryService
        .clearChatHistory()
        .timeout(const Duration(seconds: 3));
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

  void _replaceThinkingWithMessage(ChatMessage? thinking, String message) {
    final visible = (state.value ?? const [])
        .where((message) => thinking == null
            ? message.content != 'Sakhi is thinking...'
            : message.content != thinking.content)
        .toList();
    state = AsyncData([...visible]);
    _appendAssistant(message);
  }

  void _appendAssistant(String message) {
    state = AsyncData([
      ...state.value ?? const [],
      ChatMessage(
        content: message,
        role: 'assistant',
        timestamp: DateTime.now(),
        sessionId: 'sakhi_local_memory',
      ),
    ]);
  }

  String _modeContext() {
    final profile = ref.read(userProfileProvider).value;
    if (profile?.isPregnant == true) {
      return 'User has enabled pregnancy support mode. Do not diagnose. Give gentle pregnancy-safe support and recommend doctor or ASHA guidance for concerns.';
    }
    return 'User is using personal cycle tracking mode.';
  }
}
