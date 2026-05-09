import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart' as llama;

import 'sakhi_memory_service.dart';
import 'sakhi_model_manager.dart';

const bool kUseSakhiMockModel = false;
const bool kDisableSakhiMemoryForDebug = false;

class SakhiAiService {
  SakhiAiService({
    SakhiMemoryService? memoryService,
    SakhiModelManager? modelManager,
  })  : _memory = memoryService ?? SakhiMemoryService(),
        _modelManager = modelManager ?? SakhiModelManager();

  final SakhiMemoryService _memory;
  final SakhiModelManager _modelManager;

  llama.LlamaController? _controller;
  bool _isLoaded = false;
  Future<void>? _loadingFuture;

  SakhiMemoryService get memoryService => _memory;
  SakhiModelManager get modelManager => _modelManager;

  Future<bool> hasUsableModel() => _modelManager.hasUsableModel();

  Future<bool> isModelDownloaded() => hasUsableModel();

  Future<void> downloadModel(
    SakhiModelTier tier, {
    required void Function(SakhiDownloadProgress progress) onProgress,
    bool Function()? shouldCancel,
  }) async {
    await _modelManager.downloadModel(
      tier,
      onProgress: onProgress,
      shouldCancel: shouldCancel,
    );
  }

  Future<void> loadModel() {
    if (_isLoaded && _controller != null) return Future.value();
    final activeLoad = _loadingFuture;
    if (activeLoad != null) return activeLoad;

    _loadingFuture = _loadModelInternal()
        .timeout(const Duration(seconds: 45))
        .then<void>((_) {
      _isLoaded = true;
    }).catchError((Object error, StackTrace stackTrace) {
      _isLoaded = false;
      debugPrint('[SakhiAI] loadModel failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw error;
    }).whenComplete(() => _loadingFuture = null);
    return _loadingFuture!;
  }

  Future<void> _loadModelInternal() async {
    _log('loadModel start');
    final validation = await _modelManager.validateSelectedModel();
    if (!validation.isValid || validation.path == null) {
      throw const SakhiModelException(
        "Sakhi's offline AI model is missing or incomplete. Please download it again.",
      );
    }
    final file = await _modelManager.selectedModelFile();
    if (file == null) {
      throw const SakhiModelException(
        "Sakhi's offline AI model is missing or incomplete. Please download it again.",
      );
    }

    final controller = _controller ?? llama.LlamaController();
    _controller = controller;
    if (await controller.isModelLoaded()) {
      _log('loadModel success');
      return;
    }

    await controller.loadModel(
      modelPath: file.path,
      threads: _safeThreadCount(),
      contextSize: 1024,
      gpuLayers: 0,
    );
    _log('loadModel success');
  }

  Future<String> generateReply({
    required String userMessage,
    required String languageCode,
  }) async {
    _log('generation start');

    final safety = _safetyReply(userMessage);
    if (safety != null) {
      _log('generation complete length=${safety.length}');
      return safety;
    }

    final boundary = _healthBoundaryReply(userMessage, languageCode);
    if (boundary != null) {
      _log('generation complete length=${boundary.length}');
      return boundary;
    }

    if (kUseSakhiMockModel) {
      await Future<void>.delayed(const Duration(seconds: 1));
      const reply =
          "I hear you. That sounds important, and I'm here with you. Can you tell me a little more about what happened?";
      _log('generation complete length=${reply.length}');
      return reply;
    }

    try {
      final validation = await _modelManager.validateSelectedModel();
      if (!validation.isValid) {
        _log('generation failed: invalid model ${validation.errorMessage}');
        return "Sakhi's offline AI model is missing or incomplete. Please download it again.";
      }
      await loadModel().timeout(const Duration(seconds: 45));

      final messages = await _buildMessages(userMessage, languageCode);
      final controller = _controller;
      if (controller == null) {
        throw StateError('Sakhi runtime is not loaded');
      }

      final buffer = StringBuffer();
      var timedOut = false;
      final started = DateTime.now();

      try {
        await for (final token in controller
            .generateChat(
          messages: messages,
          template: 'chatml',
          maxTokens: 120,
          temperature: .7,
          topP: .9,
          topK: 40,
          repeatPenalty: 1.1,
          seed: DateTime.now().millisecondsSinceEpoch % 100000,
        )
            .timeout(
          const Duration(seconds: 35),
          onTimeout: (sink) {
            timedOut = true;
            sink.close();
          },
        )) {
          if (DateTime.now().difference(started) >
              const Duration(seconds: 35)) {
            timedOut = true;
            break;
          }
          if (token.trim().isNotEmpty) buffer.write(_cleanToken(token));
        }
      } finally {
        if (timedOut || controller.isGenerating) {
          unawaited(controller.stop().timeout(
                const Duration(seconds: 3),
                onTimeout: () {},
              ));
        }
        _log('generation finished cleanup');
      }

      if (timedOut) {
        throw TimeoutException('Sakhi generation exceeded timeout');
      }

      final reply = _sanitizeReply(buffer.toString(), userMessage);
      _log('generation success length=${reply.length}');
      return reply;
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('[SakhiAI] generation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return 'Sakhi is taking too long to respond. Please try again.';
    } catch (error, stackTrace) {
      debugPrint('[SakhiAI] generation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return "I'm having trouble thinking right now. Please try again.";
    }
  }

  Future<void> persistConversationInBackground(
    String userMessage,
    String reply,
  ) async {
    unawaited(_persistConversation(userMessage, reply));
  }

  Future<void> stopGeneration() async {
    try {
      await _controller?.stop().timeout(const Duration(seconds: 3));
    } catch (error) {
      _log('stop failed: $error');
    }
  }

  Future<void> unloadModel() async {
    await _controller?.dispose();
    _controller = null;
    _isLoaded = false;
  }

  Future<void> dispose() => unloadModel();

  Future<List<llama.ChatMessage>> _buildMessages(
    String userMessage,
    String languageCode,
  ) async {
    final recent = kDisableSakhiMemoryForDebug
        ? const <SakhiChatMessage>[]
        : await _memory
            .getRecentChatMessages(limit: 8)
            .timeout(const Duration(seconds: 3), onTimeout: () => const []);
    final memories = kDisableSakhiMemoryForDebug
        ? const <SakhiMemory>[]
        : await _memory
            .getRelevantMemories(userMessage)
            .timeout(const Duration(seconds: 3), onTimeout: () => const []);

    final memoryText = memories.isEmpty
        ? '- No saved local preferences yet.'
        : memories
            .take(5)
            .map((memory) => '- User shared previously: ${memory.value}')
            .join('\n');

    return [
      llama.ChatMessage(
        role: 'system',
        content: '''
$_systemPrompt

LANGUAGE STYLE:
$languageCode

LOCAL MEMORY:
$memoryText
''',
      ),
      for (final message in recent.take(8))
        llama.ChatMessage(
          role: message.role == 'assistant' ? 'assistant' : 'user',
          content: message.content,
        ),
      llama.ChatMessage(role: 'user', content: userMessage),
    ];
  }

  Future<void> _persistConversation(String userMessage, String reply) async {
    if (kDisableSakhiMemoryForDebug) return;
    try {
      await _memory
          .saveChatMessage(role: 'user', content: userMessage)
          .timeout(const Duration(seconds: 3));
      await _memory
          .saveChatMessage(role: 'assistant', content: reply)
          .timeout(const Duration(seconds: 3));
      await _memory
          .extractAndSaveMemories(
            userMessage: userMessage,
            assistantReply: reply,
          )
          .timeout(const Duration(seconds: 3));
    } catch (error, stackTrace) {
      debugPrint('[SakhiAI] memory persistence failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  int _safeThreadCount() {
    if (Platform.numberOfProcessors <= 2) return 1;
    return 2;
  }

  static const _systemPrompt = '''
You are Sakhi, a warm offline companion inside the Asmita app for adolescent girls.
You are friendly, gentle, and supportive, like a caring elder sister.
You are not a doctor and you must never diagnose PCOS or any disease.
Your job is to listen, comfort, explain simple health concepts, and encourage the girl to speak to an ASHA worker, trusted adult, or doctor when needed.
Keep replies short, clear, and kind.
Never shame the user.
Never create fear.
Never say "PCOS detected", "you have PCOS", "diagnosis confirmed", "disease confirmed", or "abnormal".
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
    if (!_hasAny(lower, ['pcos', 'diagnose', 'positive', 'do i have'])) {
      return null;
    }
    if (languageCode == 'manglish' || languageCode == 'malayalam') {
      return "Njan PCOS diagnose cheyyan kazhiyilla. Periods often delayed aano, acne or unusual hair growth undo, worry undenkil ASHA worker allenkil doctor-ode discuss cheyyunnath nallathaanu. Screening help cheyyum.";
    }
    if (languageCode == 'hindi') {
      return "Main PCOS diagnose nahi kar sakti. Agar periods aksar delayed hain, acne ya unusual hair growth hai, ya aap worried ho, ASHA worker ya doctor se baat karna achha rahega. Screening se samajhne mein help mil sakti hai.";
    }
    return "I can't diagnose PCOS. But if your periods are often delayed, you notice acne or unusual hair growth, or you're worried, it's worth discussing with an ASHA worker or doctor. Screening can help you understand what's going on.";
  }

  String _sanitizeReply(String raw, String userMessage) {
    var text = raw
        .replaceAll('<start_of_turn>', '')
        .replaceAll('<end_of_turn>', '')
        .replaceAll('<|im_start|>', '')
        .replaceAll('<|im_end|>', '')
        .replaceAll('<eos>', '')
        .replaceAll(
          RegExp(r'^(Sakhi|Assistant|Model)\s*:\s*', caseSensitive: false),
          '',
        )
        .trim();
    final lower = text.toLowerCase();
    final user = userMessage.trim().toLowerCase();
    if (text.isEmpty) {
      return "I'm not sure how to answer that yet, but I'm here with you. Can you say it another way?";
    }
    if (lower == user ||
        (lower.length <= user.length + 8 && lower.contains(user)) ||
        _hasAny(lower, [
          'pcos detected',
          'you have pcos',
          'you are abnormal',
          'disease confirmed',
          'diagnosis confirmed',
          'as a language model',
          'capabilities are limited',
        ])) {
      return "I'm having trouble thinking right now. Please try again.";
    }
    return text
        .replaceAll(
          RegExp('PCOS detected', caseSensitive: false),
          'screening may help',
        )
        .replaceAll(
          RegExp('you have PCOS', caseSensitive: false),
          'it may be worth discussing this with a doctor',
        )
        .replaceAll(
          RegExp('abnormal', caseSensitive: false),
          'worth discussing',
        );
  }

  String _cleanToken(String token) {
    return token
        .replaceAll('<start_of_turn>', '')
        .replaceAll('<end_of_turn>', '')
        .replaceAll('<|im_start|>', '')
        .replaceAll('<|im_end|>', '')
        .replaceAll('<eos>', '');
  }

  bool _hasAny(String text, List<String> patterns) {
    return patterns.any(text.contains);
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[SakhiAI] $message');
  }
}
