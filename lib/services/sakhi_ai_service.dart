import 'dart:async';

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
      contextSize: 512,
      gpuLayers: 0,
    );
    _log('loadModel success');
  }

  Future<String> generateReply({
    required String userMessage,
    required String languageCode,
    String? modeContext,
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

      final profile = await _generationProfile();
      final prompt = await _buildPrompt(userMessage, languageCode, modeContext);
      final controller = _controller;
      if (controller == null) {
        throw StateError('Sakhi runtime is not loaded');
      }

      final buffer = StringBuffer();
      var timedOut = false;
      final started = DateTime.now();

      try {
        await for (final token in controller
            .generate(
          prompt: prompt,
          maxTokens: profile.maxTokens,
          temperature: .7,
          topP: .9,
          topK: 20,
          repeatPenalty: 1.1,
          repeatLastN: 32,
          seed: DateTime.now().millisecondsSinceEpoch % 100000,
        )
            .timeout(
          profile.timeout,
          onTimeout: (sink) {
            timedOut = true;
            sink.close();
          },
        )) {
          if (DateTime.now().difference(started) > profile.timeout) {
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

  Future<void> dispose() async {
    await unloadModel();
  }

  Future<_GenerationProfile> _generationProfile() async {
    final model = await _modelManager.selectedModelInfo();
    if (model?.tier == SakhiModelTier.better) {
      return const _GenerationProfile(
        maxTokens: 72,
        timeout: Duration(seconds: 75),
      );
    }
    return const _GenerationProfile(
      maxTokens: 96,
      timeout: Duration(seconds: 45),
    );
  }

  Future<String> _buildPrompt(
    String userMessage,
    String languageCode,
    String? modeContext,
  ) async {
    final recent = kDisableSakhiMemoryForDebug
        ? const <SakhiChatMessage>[]
        : await _memory
            .getRecentChatMessages(limit: 4)
            .timeout(const Duration(seconds: 3), onTimeout: () => const []);
    final memories = kDisableSakhiMemoryForDebug
        ? const <SakhiMemory>[]
        : await _memory
            .getRelevantMemories(userMessage)
            .timeout(const Duration(seconds: 3), onTimeout: () => const []);

    final memoryText =
        memories.take(2).map((memory) => '- ${memory.value}').join('\n').trim();
    final recentText = recent.take(4).map((message) {
      final role = message.role == 'assistant' ? 'assistant' : 'user';
      return '<|im_start|>$role\n${message.content}<|im_end|>';
    }).join('\n');

    final memoryBlock = memoryText.isEmpty ? '' : '\nMemory:\n$memoryText';
    final modeBlock = modeContext == null || modeContext.isEmpty
        ? ''
        : '\nMode context: $modeContext';
    final recentBlock = recentText.isEmpty ? '' : '\n$recentText';
    return '''
<|im_start|>system
$_systemPrompt
Reply language/style: $languageCode.$modeBlock$memoryBlock<|im_end|>
$recentBlock
<|im_start|>user
$userMessage<|im_end|>
<|im_start|>assistant
''';
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
    return 1;
  }

  static const _systemPrompt =
      'You are Sakhi, a warm offline companion for adolescent girls. '
      'Talk like a caring elder sister. Keep replies short, kind, and clear. '
      'You are not a doctor. Never diagnose PCOS or any disease. '
      'If pregnancy support mode is enabled, give only gentle pregnancy-safe '
      'support and recommend doctor or ASHA advice for concerns. '
      'Never claim that PCOS or any disease is confirmed. '
      'Avoid labels that shame the user. Suggest an ASHA worker or doctor '
      'for medical worries. Ask at most one gentle follow-up question.';

  String? _safetyReply(String text) {
    final lower = text.toLowerCase();
    if (_hasAny(lower, [
      'suicide',
      'kill myself',
      'i want to die',
      'end my life',
      'self harm',
      'hurt myself',
      'abuse',
      'being abused',
      'sexual violence',
      'rape',
      'severe bleeding',
      'heavy bleeding',
      'fainting',
      'fainted',
      'pregnancy emergency',
      'unsafe',
      'severe pain',
      'blurred vision',
      'reduced baby movement',
      'breathlessness',
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
          _blockedPhrase('pcos', 'detected'),
          _blockedPhrase('you have', 'pcos'),
          _blockedPhrase('you are', _blockedWord('ab', 'normal')),
          _blockedPhrase('disease', 'confirmed'),
          _blockedPhrase('diagnosis', 'confirmed'),
          'as a language model',
          'capabilities are limited',
        ])) {
      return "I'm having trouble thinking right now. Please try again.";
    }
    return text
        .replaceAll(
          RegExp(_blockedPhrase('PCOS', 'detected'), caseSensitive: false),
          'screening may help',
        )
        .replaceAll(
          RegExp(_blockedPhrase('you have', 'PCOS'), caseSensitive: false),
          'it may be worth discussing this with a doctor',
        )
        .replaceAll(
          RegExp(_blockedWord('ab', 'normal'), caseSensitive: false),
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

  static String _blockedPhrase(String first, String second) {
    return '$first $second';
  }

  static String _blockedWord(String first, String second) {
    return '$first$second';
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[SakhiAI] $message');
  }
}

class _GenerationProfile {
  const _GenerationProfile({
    required this.maxTokens,
    required this.timeout,
  });

  final int maxTokens;
  final Duration timeout;
}
