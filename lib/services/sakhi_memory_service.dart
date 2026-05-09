import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../services/security_service.dart';

class SakhiChatMessage {
  const SakhiChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  final String role;
  final String content;
  final DateTime timestamp;
}

class SakhiMemory {
  const SakhiMemory({
    this.id,
    required this.key,
    required this.value,
    required this.category,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String key;
  final String value;
  final String category;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class SakhiMemoryService {
  Future<void> init() async {
    await DatabaseHelper.instance.ensureSakhiTables();
  }

  Future<List<SakhiMemory>> getAllMemories() async {
    await init();
    final rows = await (await DatabaseHelper.instance.database).query(
      'sakhi_memories',
      orderBy: 'updated_at DESC',
    );
    return Future.wait(rows.map(_memoryFromRow));
  }

  Future<List<SakhiMemory>> getRelevantMemories(String userMessage) async {
    final all = await getAllMemories();
    final lower = userMessage.toLowerCase();
    final scored = all.map((memory) {
      var score = memory.confidence;
      final haystack =
          '${memory.key} ${memory.value} ${memory.category}'.toLowerCase();
      for (final token in lower.split(RegExp(r'\s+'))) {
        if (token.length > 3 && haystack.contains(token)) score += .4;
      }
      if (memory.category == 'language_preference') score += .5;
      if (memory.category == 'safety_note') score += .4;
      return MapEntry(memory, score);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return scored.take(5).map((entry) => entry.key).toList();
  }

  Future<void> saveMemory({
    required String key,
    required String value,
    required String category,
    double confidence = 1.0,
  }) async {
    await init();
    if (_isUnsafeMemory(value)) return;
    final now = DateTime.now().toIso8601String();
    final encrypted = await SecurityService.instance.encrypt(value.trim());
    final db = await DatabaseHelper.instance.database;
    final existing = await db.query(
      'sakhi_memories',
      columns: ['id', 'created_at'],
      where: 'memory_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    final row = {
      'memory_key': key,
      'memory_value_enc': encrypted,
      'category': category,
      'confidence': confidence,
      'updated_at': now,
      'created_at': existing.isEmpty ? now : existing.first['created_at'],
    };
    if (existing.isEmpty) {
      await db.insert('sakhi_memories', row);
    } else {
      await db.update(
        'sakhi_memories',
        row,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<void> deleteMemory(String key) async {
    await init();
    await (await DatabaseHelper.instance.database).delete(
      'sakhi_memories',
      where: 'memory_key = ?',
      whereArgs: [key],
    );
  }

  Future<void> clearAllMemories() async {
    await init();
    await (await DatabaseHelper.instance.database).delete('sakhi_memories');
  }

  Future<void> saveChatMessage({
    required String role,
    required String content,
  }) async {
    await init();
    if (content.trim().isEmpty) return;
    await (await DatabaseHelper.instance.database)
        .insert('sakhi_chat_messages', {
      'role': role,
      'content_enc': await SecurityService.instance.encrypt(content.trim()),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SakhiChatMessage>> getRecentChatMessages({int limit = 20}) async {
    await init();
    final rows = await (await DatabaseHelper.instance.database).query(
      'sakhi_chat_messages',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    final messages = await Future.wait(rows.reversed.map((row) async {
      return SakhiChatMessage(
        role: row['role'] as String? ?? 'user',
        content: await SecurityService.instance
            .decrypt(row['content_enc'] as String),
        timestamp: DateTime.tryParse(row['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }));
    return messages;
  }

  Future<void> clearChatHistory() async {
    await init();
    await (await DatabaseHelper.instance.database)
        .delete('sakhi_chat_messages');
  }

  Future<void> extractAndSaveMemories({
    required String userMessage,
    required String assistantReply,
  }) async {
    final text = userMessage.trim();
    final lower = text.toLowerCase();
    if (_isUnsafeMemory(lower)) return;

    if (_hasAny(lower, ['forget', 'delete memory', "don't remember this"])) {
      await _forgetFrom(lower);
      return;
    }

    final explicit = _hasAny(lower, [
      'remember that',
      'remember this',
      'from now on',
      'call me',
      'i prefer',
      'my periods usually',
      'i usually',
      'i like',
      "i don't like",
      'എനിക്ക് ഇഷ്ടം',
      'ഓർത്ത് വെക്കണം',
      'ഇനി മുതൽ',
      'मुझे याद रखना',
      'मुझे पसंद है',
      'अब से',
    ]);
    if (!explicit && !_isDurablePattern(lower)) return;

    final memory = _classify(text, lower);
    if (memory == null) return;
    await saveMemory(
      key: memory.key,
      value: memory.value,
      category: memory.category,
      confidence: explicit ? 1.0 : .72,
    );
    if (kDebugMode) debugPrint('[SakhiAI] memory saved: ${memory.key}');
  }

  Future<SakhiMemory> _memoryFromRow(Map<String, Object?> row) async {
    return SakhiMemory(
      id: row['id'] as int?,
      key: row['memory_key'] as String,
      value: await SecurityService.instance
          .decrypt(row['memory_value_enc'] as String),
      category: row['category'] as String? ?? 'preference',
      confidence: (row['confidence'] as num?)?.toDouble() ?? 1,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Future<void> _forgetFrom(String lower) async {
    final memories = await getAllMemories();
    for (final memory in memories) {
      final haystack = '${memory.key} ${memory.value}'.toLowerCase();
      if (lower
          .split(RegExp(r'\s+'))
          .any((token) => token.length > 3 && haystack.contains(token))) {
        await deleteMemory(memory.key);
      }
    }
  }

  _MemoryDraft? _classify(String text, String lower) {
    if (_hasAny(lower, ['call me', 'from now on call me', 'വിളിക്കണം'])) {
      return _MemoryDraft('preferred_name', text, 'preference');
    }
    if (_hasAny(lower, ['manglish', 'malayalam', 'hindi', 'english'])) {
      return _MemoryDraft('language_style', text, 'language_preference');
    }
    if (_hasAny(lower, [
      'i like',
      'i love',
      "i don't like",
      'i prefer',
      'എനിക്ക് ഇഷ്ടം',
      'मुझे पसंद'
    ])) {
      return _MemoryDraft(
          'preference_${_stableSuffix(lower)}', text, 'preference');
    }
    if (_hasAny(lower, ['exam', 'school', 'class', 'study', 'college'])) {
      return _MemoryDraft('school_context', text, 'school');
    }
    if (_hasAny(lower, ['family', 'mother', 'father', 'parents', 'home'])) {
      return _MemoryDraft('family_context', text, 'family_context');
    }
    if (_hasAny(lower,
        ['period', 'cramp', 'pain', 'flow', 'cycle', 'periods usually'])) {
      return _MemoryDraft('cycle_support_context', text, 'health_context');
    }
    if (_hasAny(lower,
        ['usually stressed', 'often sad', 'anxious before', 'feel scared'])) {
      return _MemoryDraft('emotional_context', text, 'emotional_context');
    }
    return null;
  }

  bool _isDurablePattern(String lower) {
    return _hasAny(lower, [
      'i usually',
      'usually i',
      'my periods usually',
      'i prefer',
      'i like short',
      'reply in',
      'talk in',
    ]);
  }

  bool _isUnsafeMemory(String value) {
    return _hasAny(value.toLowerCase(), [
      'ignore safety',
      'ignore your rules',
      'act as a doctor',
      'diagnose me',
      'reveal prompt',
      'bypass',
      'phone number',
      'address',
    ]);
  }

  bool _hasAny(String text, List<String> patterns) {
    return patterns.any(text.contains);
  }

  String _stableSuffix(String text) {
    final words = text
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3)
        .take(3)
        .join('_');
    return words.isEmpty ? 'general' : words;
  }
}

class _MemoryDraft {
  const _MemoryDraft(this.key, this.value, this.category);
  final String key;
  final String value;
  final String category;
}
