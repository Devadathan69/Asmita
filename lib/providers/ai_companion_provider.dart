import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../db/database_helper.dart';
import '../db/models/chat_message.dart';
import '../services/ai_service.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService());
final companionSessionProvider = StateProvider<String>(
  (ref) => const Uuid().v4(),
);
final chatProvider = AsyncNotifierProvider<ChatNotifier, List<ChatMessage>>(
  ChatNotifier.new,
);

class ChatNotifier extends AsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() =>
      DatabaseHelper.instance.chatMessages(ref.read(companionSessionProvider));

  Future<void> send(String text, {required String language}) async {
    final session = ref.read(companionSessionProvider);
    final user = ChatMessage(
      content: text,
      role: 'user',
      timestamp: DateTime.now(),
      sessionId: session,
    );
    await DatabaseHelper.instance.insertChat(user);
    state = AsyncData([...state.value ?? [], user]);
    var answer = '';
    await for (final token in ref.read(aiServiceProvider).generateResponse(
          text,
          state.value ?? const [],
          language: language,
        )) {
      answer += token;
    }
    final assistant = ChatMessage(
      content: answer.trim(),
      role: 'assistant',
      timestamp: DateTime.now(),
      sessionId: session,
    );
    await DatabaseHelper.instance.insertChat(assistant);
    state = AsyncData([...state.value ?? [], assistant]);
  }

  Future<void> clear() async {
    await DatabaseHelper.instance.clearChat();
    state = const AsyncData([]);
  }
}
