class ChatMessage {
  const ChatMessage({
    this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    required this.sessionId,
  });
  final int? id;
  final String content;
  final String role;
  final DateTime timestamp;
  final String sessionId;
}
