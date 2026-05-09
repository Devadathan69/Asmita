import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

import 'network_privacy_service.dart';
import 'sakhi_memory_service.dart';

class SakhiAiService {
  SakhiAiService({
    NetworkPrivacyService network = const NetworkPrivacyService(),
    SakhiMemoryService? memoryService,
  })  : _network = network,
        _memory = memoryService ?? SakhiMemoryService();

  static const modelFileName =
      'SmolLM-135M-Instruct_multi-prefill-seq_q8_ekv1280.task';
  static const modelUrl = String.fromEnvironment(
    'SAKHI_MODEL_URL',
    defaultValue:
        'https://huggingface.co/litert-community/SmolLM-135M-Instruct/resolve/main/$modelFileName',
  );
  static const expectedSha256 = String.fromEnvironment(
    'SAKHI_MODEL_SHA256',
    defaultValue:
        '6987dce5ac4f71032b070cf13412a5de0e49c04d271a053fc7d9d59a0dc104e9',
  );

  final NetworkPrivacyService _network;
  final SakhiMemoryService _memory;
  InferenceModel? _model;
  bool _initialized = false;
  double _downloadProgress = 0;

  SakhiMemoryService get memoryService => _memory;

  Future<File> _modelFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/models/sakhi_model.task');
  }

  Future<void> _initGemma() async {
    if (_initialized) return;
    await FlutterGemma.initialize(maxDownloadRetries: 3);
    await _memory.init();
    _initialized = true;
  }

  Future<bool> isModelDownloaded() async {
    final file = await _modelFile();
    return file.existsSync() && file.lengthSync() > 0;
  }

  Future<double> getDownloadProgress() async => _downloadProgress;

  Future<void> downloadModel({
    required void Function(double progress) onProgress,
  }) async {
    await _initGemma();
    final file = await _modelFile();
    if (await isModelDownloaded()) {
      _downloadProgress = 1;
      onProgress(1);
      return;
    }
    await _network.downloadFile(
      modelUrl,
      file,
      onProgress: (progress) {
        _downloadProgress = progress * .92;
        onProgress(_downloadProgress);
      },
    );
    await _verifyModel(file);
    await FlutterGemma.installModel(modelType: ModelType.general)
        .fromFile(file.path)
        .withProgress((progress) {
      _downloadProgress = .92 + ((progress / 100) * .08);
      onProgress(_downloadProgress);
    }).install();
    _downloadProgress = 1;
    onProgress(1);
  }

  Future<void> loadModel() async {
    await _initGemma();
    if (!await isModelDownloaded()) {
      throw StateError(
          'Sakhi is not ready yet. Please download the offline AI model first.');
    }
    final file = await _modelFile();
    await _verifyModel(file);
    await FlutterGemma.installModel(modelType: ModelType.general)
        .fromFile(file.path)
        .install();
    _model ??= await _createModel(PreferredBackend.gpu).catchError((_) {
      return _createModel(PreferredBackend.cpu);
    });
  }

  Future<String> generateReply({
    required List<SakhiChatMessage> history,
    required String userMessage,
    required String languageCode,
  }) async {
    final safety = _safetyReply(userMessage);
    if (safety != null) {
      await _memory.saveChatMessage(role: 'user', content: userMessage);
      await _memory.saveChatMessage(role: 'assistant', content: safety);
      return safety;
    }

    final boundary = _healthBoundaryReply(userMessage, languageCode);
    if (boundary != null) {
      await _memory.saveChatMessage(role: 'user', content: userMessage);
      await _memory.saveChatMessage(role: 'assistant', content: boundary);
      await _memory.extractAndSaveMemories(
        userMessage: userMessage,
        assistantReply: boundary,
      );
      return boundary;
    }

    try {
      if (!await isModelDownloaded()) {
        return 'Sakhi is not ready yet. Please download the offline AI model first.';
      }
      await loadModel().timeout(const Duration(seconds: 45));
      final recent = await _memory.getRecentChatMessages(limit: 8);
      final memories = await _memory.getRelevantMemories(userMessage);
      final prompt = _buildPrompt(
        memories: memories,
        history: recent.isEmpty ? history.take(8).toList() : recent,
        userMessage: userMessage,
        languageCode: languageCode,
      );
      final chat = await _model!
          .createChat(
            temperature: .7,
            topK: 40,
            topP: .9,
            randomSeed: DateTime.now().millisecondsSinceEpoch % 100000,
            tokenBuffer: 180,
            systemInstruction: _systemPrompt,
          )
          .timeout(const Duration(seconds: 20));
      final buffer = StringBuffer();
      var timedOut = false;
      try {
        await chat
            .addQueryChunk(Message.text(text: prompt, isUser: true))
            .timeout(const Duration(seconds: 20));
        var words = 0;
        await for (final response in chat.generateChatResponseAsync().timeout(
          const Duration(seconds: 45),
          onTimeout: (sink) {
            timedOut = true;
            sink.close();
          },
        )) {
          if (response case TextResponse(:final token)) {
            final cleaned = _cleanToken(token);
            if (cleaned.trim().isEmpty) continue;
            words += cleaned.split(RegExp(r'\s+')).length;
            if (words > 190) break;
            buffer.write(cleaned);
          }
        }
      } finally {
        await chat.close().timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
      }

      if (timedOut && buffer.isEmpty) {
        throw TimeoutException('Sakhi model did not return tokens in time');
      }

      final reply = _sanitizeReply(buffer.toString(), userMessage);
      await _memory.saveChatMessage(role: 'user', content: userMessage);
      await _memory.saveChatMessage(role: 'assistant', content: reply);
      await _memory.extractAndSaveMemories(
        userMessage: userMessage,
        assistantReply: reply,
      );
      return reply;
    } catch (error, stackTrace) {
      debugPrint('Sakhi generation failed: $error\n$stackTrace');
      return "I'm having trouble thinking right now. Please try again.";
    }
  }

  Future<void> dispose() async {
    await _model?.close();
    _model = null;
  }

  Future<InferenceModel> _createModel(PreferredBackend backend) {
    return FlutterGemma.getActiveModel(
      maxTokens: 1024,
      preferredBackend: backend,
    );
  }

  Future<void> _verifyModel(File file) async {
    if (!file.existsSync() || file.lengthSync() == 0) {
      throw const NetworkPrivacyException('Model file is empty');
    }
    if (expectedSha256.isEmpty) return;
    final digest = sha256.convert(await file.readAsBytes()).toString();
    if (digest != expectedSha256) {
      await file.delete();
      throw const NetworkPrivacyException('Model verification failed');
    }
  }

  String _buildPrompt({
    required List<SakhiMemory> memories,
    required List<SakhiChatMessage> history,
    required String userMessage,
    required String languageCode,
  }) {
    final memoryText = memories.isEmpty
        ? '- No saved local preferences yet.'
        : memories
            .map((m) => '- User shared previously: ${m.value}')
            .join('\n');
    final recent = history.take(8).map((m) {
      final role = m.role == 'assistant' ? 'Sakhi' : 'User';
      return '$role: ${m.content}';
    }).join('\n');
    return '''
$_systemPrompt

LANGUAGE STYLE:
$languageCode

LOCAL MEMORY:
$memoryText

RECENT CHAT:
$recent

CURRENT USER MESSAGE:
$userMessage

Sakhi:
''';
  }

  static const _systemPrompt = '''
You are Sakhi, a warm offline companion inside the Asmita app for adolescent girls.
You are friendly, gentle, and supportive, like a caring elder sister.
You are not a doctor and you must never diagnose PCOS or any disease.
Your job is to listen, comfort, explain simple health concepts, and encourage the girl to speak to an ASHA worker, trusted adult, or doctor when needed.
Keep replies short, clear, and kind.
Never shame the user.
Never create fear.
Never say "PCOS detected", "you have PCOS", "diagnosis", "disease confirmed", or "abnormal".
Use phrases like "worth discussing with a doctor", "screening may help", or "a health worker can guide you".
If the user asks about emergency symptoms, advise immediate help from a trusted adult or doctor.
If the user writes in Malayalam, Hindi, or Manglish, reply in the same language/style as much as possible.
Ask at most one gentle follow-up question.
''';

  String? _safetyReply(String text) {
    final lower = text.toLowerCase();
    if (_hasAny(lower, [
      'suicide',
      'kill myself',
      'self harm',
      'hurt myself',
      'abuse',
      'sexual violence',
      'rape',
      'severe bleeding',
      'fainting',
      'pregnancy emergency',
      'unsafe',
    ])) {
      return "I'm really sorry you're facing this. Please don't stay alone with it - tell a trusted adult near you now, or contact local emergency medical help. You deserve support immediately.";
    }
    return null;
  }

  String? _healthBoundaryReply(String text, String languageCode) {
    final lower = text.toLowerCase();
    if (!_hasAny(lower, ['pcos', 'diagnose', 'positive', 'do i have']))
      return null;
    if (languageCode == 'manglish' || languageCode == 'malayalam') {
      return "Njan PCOS diagnose cheyyan kazhiyilla. Periods often delayed aano, acne or unusual hair growth undo, worry undenkil ASHA worker allenkil doctor-ode discuss cheyyunnath nallathaanu. Screening help cheyyum.";
    }
    if (languageCode == 'hindi') {
      return "Main PCOS diagnose nahi kar sakti. Agar periods aksar delayed hain, acne ya unusual hair growth hai, ya aap worried ho, ASHA worker ya doctor se baat karna achha rahega. Screening se samajhne mein help mil sakti hai.";
    }
    return "I can't diagnose PCOS. But if your periods are often delayed, you notice acne or unusual hair growth, or you're worried, it's worth discussing with an ASHA worker or doctor. Screening can help you understand what is going on.";
  }

  String _sanitizeReply(String raw, String userMessage) {
    var text = raw
        .replaceAll('<start_of_turn>', '')
        .replaceAll('<end_of_turn>', '')
        .replaceAll('<eos>', '')
        .replaceAll(
            RegExp(r'^(Sakhi|Assistant|Model)\s*:\s*', caseSensitive: false),
            '')
        .trim();
    final lower = text.toLowerCase();
    final user = userMessage.trim().toLowerCase();
    if (text.isEmpty ||
        lower == user ||
        (lower.length <= user.length + 8 && lower.contains(user)) ||
        _hasAny(lower, [
          'pcos detected',
          'you have pcos',
          'you are abnormal',
          'disease confirmed',
          'as a language model',
          'capabilities are limited',
        ])) {
      return "I'm having trouble thinking right now. Please try again.";
    }
    text = text
        .replaceAll(
            RegExp('PCOS detected', caseSensitive: false), 'screening may help')
        .replaceAll(RegExp('you have PCOS', caseSensitive: false),
            'it may be worth discussing this with a doctor')
        .replaceAll(
            RegExp('abnormal', caseSensitive: false), 'worth discussing');
    return text;
  }

  String _cleanToken(String token) {
    return token
        .replaceAll('<start_of_turn>', '')
        .replaceAll('<end_of_turn>', '')
        .replaceAll('<eos>', '');
  }

  bool _hasAny(String text, List<String> patterns) =>
      patterns.any(text.contains);
}
