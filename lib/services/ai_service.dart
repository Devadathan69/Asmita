import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

import '../db/models/chat_message.dart';
import 'network_privacy_service.dart';

enum SakhiEngine { gemma, localFallback }

class AiService {
  AiService({NetworkPrivacyService network = const NetworkPrivacyService()})
      : _network = network;

  static const modelFileName = 'gemma3-270m-it-q8.task';
  static const bundledAsset = 'assets/models/$modelFileName';
  static const defaultModelUrl =
      'https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/$modelFileName';
  static const modelUrl = String.fromEnvironment(
    'SAKHI_GEMMA_MODEL_URL',
    defaultValue: defaultModelUrl,
  );
  static const expectedSha256 = String.fromEnvironment(
    'SAKHI_GEMMA_SHA256',
    defaultValue:
        '0f7147f1c22eaf758b819bbf7841793e4c90096c9352cde7fbe5c631f2265ef5',
  );

  final NetworkPrivacyService _network;
  InferenceModel? _model;
  bool _initialized = false;
  SakhiEngine _engine = SakhiEngine.localFallback;

  SakhiEngine get engine => _engine;
  bool get isUsingGemma => _engine == SakhiEngine.gemma;

  Future<File> _downloadedModelFile() async =>
      File('${(await getApplicationDocumentsDirectory()).path}/$modelFileName');

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await FlutterGemma.initialize(maxDownloadRetries: 3);
    _initialized = true;
  }

  Future<bool> isModelAvailable() async {
    await _ensureInitialized();
    if (await FlutterGemma.isModelInstalled(modelFileName)) return true;
    final file = await _downloadedModelFile();
    return file.existsSync() && file.lengthSync() > 0;
  }

  Future<void> loadModel() async {
    await _ensureInitialized();
    await _activateInstalledOrDownloadedModel();
    try {
      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.gpu,
      );
      _engine = SakhiEngine.gemma;
    } catch (_) {
      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.cpu,
      );
      _engine = SakhiEngine.gemma;
    }
  }

  Stream<double> downloadModel() {
    final controller = StreamController<double>();
    unawaited(() async {
      try {
        await _ensureInitialized();
        if (await FlutterGemma.isModelInstalled(modelFileName)) {
          controller.add(1);
          await loadModel();
          await controller.close();
          return;
        }

        if (await _assetExists(bundledAsset)) {
          await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
              .fromAsset(bundledAsset)
              .withProgress((progress) => controller.add(progress / 100))
              .install();
        } else {
          final destination = await _downloadedModelFile();
          await _network.downloadFile(
            modelUrl,
            destination,
            onProgress: (progress) => controller.add(progress * .92),
          );
          await _verifyDownloadedModel(destination);
          await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
              .fromFile(destination.path)
              .withProgress((progress) {
            controller.add(.92 + ((progress / 100) * .08));
          }).install();
        }

        controller.add(1);
        await loadModel();
        await controller.close();
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
        await controller.close();
      }
    }());
    return controller.stream;
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final decoded = jsonDecode(manifest) as Map<String, dynamic>;
      return decoded.containsKey(assetPath);
    } catch (_) {
      return false;
    }
  }

  Future<void> _verifyDownloadedModel(File file) async {
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

  Future<void> _activateInstalledOrDownloadedModel() async {
    if (await FlutterGemma.isModelInstalled(modelFileName)) {
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromNetwork(modelUrl)
          .install();
      return;
    }

    final file = await _downloadedModelFile();
    if (file.existsSync() && file.lengthSync() > 0) {
      await _verifyDownloadedModel(file);
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromFile(file.path)
          .install();
      return;
    }

    if (await _assetExists(bundledAsset)) {
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromAsset(bundledAsset)
          .install();
      return;
    }

    throw StateError('Sakhi Gemma model is not installed');
  }

  Stream<String> generateResponse(
    String userMessage,
    List<ChatMessage> history, {
    required String language,
  }) async* {
    try {
      if (_model == null) await loadModel();
      final memory = _memorySummary(history, language);
      final chat = await _model!.createChat(
        temperature: .55,
        topK: 40,
        randomSeed: DateTime.now().millisecondsSinceEpoch % 100000,
        systemInstruction: _systemInstruction(language, memory),
      );
      final buffer = StringBuffer();
      try {
        for (final item in _contextMessages(history, userMessage)) {
          await chat.addQueryChunk(
            Message.text(text: item.content, isUser: item.role == 'user'),
          );
        }
        await chat.addQueryChunk(Message.text(text: userMessage, isUser: true));

        var emittedWords = 0;
        await for (final response in chat.generateChatResponseAsync()) {
          if (response case TextResponse(:final token)) {
            final cleaned = _cleanModelToken(token);
            if (cleaned.isEmpty) continue;
            emittedWords += cleaned.split(RegExp(r'\s+')).length;
            if (emittedWords > 320) break;
            buffer.write(cleaned);
          }
        }
      } finally {
        await chat.close();
      }
      final repaired = _repairResponse(
        userMessage: userMessage,
        modelText: buffer.toString(),
        history: history,
        language: language,
      );
      yield* _streamText(repaired);
    } catch (_) {
      _engine = SakhiEngine.localFallback;
      yield* _streamFallback(userMessage, history, language);
    }
  }

  List<ChatMessage> _contextMessages(
    List<ChatMessage> history,
    String currentMessage,
  ) {
    final withoutCurrent = history.isNotEmpty &&
            history.last.role == 'user' &&
            history.last.content.trim() == currentMessage.trim()
        ? history.take(history.length - 1)
        : history;
    return withoutCurrent
        .where((item) => item.content.trim().isNotEmpty)
        .toList()
        .reversed
        .take(6)
        .toList()
        .reversed
        .toList();
  }

  String _systemInstruction(String language, String memory) => '''
You are Sakhi, a private AI companion and gentle friend for girls and women in India.
Your first job is companionship: respond warmly to greetings, casual chat, worries, boredom, school/college stress, family pressure, emotions, confidence, dreams, friendships, and daily life.
Your second job is menstrual health support when the user asks for it.
Do not refuse normal friendly conversation. If the user says hi, greet them like a caring friend and ask how their day is.
You know your name is Sakhi. Speak as Sakhi in first person. Do not say you are only a language assistant.
If the user tells you a personal preference, worry, name, class, college, cycle detail, mood pattern, or life detail, gently remember it using the local memory below.
Respond in the user's selected language: $language.
Keep replies natural, short, and chat-like: usually 2 to 6 sentences.
Use the user's local encrypted memory only when it helps. Never say you store cloud memory.
Local memory from this device:
$memory

Health rules:
Never diagnose. Use "cycle pattern concerns" for pattern questions.
Suggest a doctor or ASHA worker for severe pain, heavy bleeding, infection signs, missed periods with pregnancy possibility, self-harm, or anything worrying.
Use Indian food and daily-life examples when useful.
Never ask for full name, phone, address, account, email, or exact location.
Be gentle, practical, culturally sensitive, and non-alarmist.
''';

  String _memorySummary(List<ChatMessage> history, String language) {
    final recent = history
        .where((item) => item.content.trim().isNotEmpty)
        .toList()
        .reversed
        .take(10)
        .toList()
        .reversed;
    if (recent.isEmpty) {
      return 'No previous local memory yet. Start fresh and friendly.';
    }
    final lines = recent.map((item) {
      final role = item.role == 'user' ? 'User' : 'Sakhi';
      final text = item.content.replaceAll(RegExp(r'\s+'), ' ').trim();
      return '$role: ${text.length > 180 ? '${text.substring(0, 180)}...' : text}';
    }).join('\n');
    final userFacts = _extractMemoryFacts(history);
    if (userFacts.isEmpty) return lines;
    return 'Remembered user details:\n${userFacts.join('\n')}\n\nRecent conversation:\n$lines';
  }

  List<String> _extractMemoryFacts(List<ChatMessage> history) {
    final facts = <String>[];
    for (final item in history.where((message) => message.role == 'user')) {
      final text = item.content.replaceAll(RegExp(r'\s+'), ' ').trim();
      final lower = text.toLowerCase();
      if (_hasAny(lower, ['my name is', 'call me', 'i am ', 'i\'m '])) {
        facts.add('- User identity/preference: $text');
      } else if (_hasAny(lower, ['i like', 'i love', 'i hate', 'favorite'])) {
        facts.add('- User preference: $text');
      } else if (_hasAny(lower, ['school', 'college', 'exam', 'class'])) {
        facts.add('- User study context: $text');
      } else if (_hasAny(lower, ['period', 'cycle', 'cramp', 'pain', 'flow'])) {
        facts.add('- User cycle/health context: $text');
      } else if (_hasAny(
          lower, ['sad', 'happy', 'angry', 'stress', 'anxious'])) {
        facts.add('- User emotional context: $text');
      }
      if (facts.length >= 8) break;
    }
    return facts;
  }

  String _repairResponse({
    required String userMessage,
    required String modelText,
    required List<ChatMessage> history,
    required String language,
  }) {
    final cleaned = modelText
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
            RegExp(r'^(Sakhi|Assistant|Model)\s*:\s*', caseSensitive: false),
            '')
        .trim();
    if (_isBadModelResponse(userMessage, cleaned)) {
      return _localCompanionResponse(userMessage, history, language);
    }
    return cleaned;
  }

  bool _isBadModelResponse(String userMessage, String response) {
    if (response.trim().isEmpty) return true;
    final lower = response.toLowerCase();
    final user = userMessage.toLowerCase().trim();
    if (lower == user) return true;
    if (lower.length <= user.length + 8 && lower.contains(user)) return true;
    return _hasAny(lower, [
      'i cannot fulfill',
      'i can not fulfill',
      'capabilities are limited',
      'limited to assisting with use of language',
      'i am unable to',
      'as a language model',
    ]);
  }

  String _cleanModelToken(String token) {
    return token
        .replaceAll('<start_of_turn>', '')
        .replaceAll('<end_of_turn>', '')
        .replaceAll('<eos>', '')
        .replaceAll(RegExp(r'model\s*$', caseSensitive: false), '');
  }

  Stream<String> _streamFallback(
    String message,
    List<ChatMessage> history,
    String language,
  ) async* {
    final response = _localCompanionResponse(message, history, language);
    yield* _streamText(response);
  }

  Stream<String> _streamText(String response) async* {
    for (final word in response.split(' ')) {
      await Future<void>.delayed(const Duration(milliseconds: 18));
      yield '$word ';
    }
  }

  String _localCompanionResponse(
    String message,
    List<ChatMessage> history,
    String language,
  ) {
    final lower = message.toLowerCase();
    final isPain = _hasAny(lower, ['pain', 'cramp', 'stomach', 'back', 'dard']);
    final isFood = _hasAny(lower, ['food', 'eat', 'diet', 'ragi', 'khana']);
    final isMood = _hasAny(lower, ['sad', 'stress', 'cry', 'mood', 'tension']);
    final variant =
        sha1.convert(utf8.encode('$lower|${history.length}')).bytes.first % 3;

    if (language == 'hindi') {
      if (_hasAny(lower, ['hi', 'hello', 'hey'])) {
        return 'Sakhi yahan hai. Hi, kaise ho? Aaj bas chat karni hai ya kuch tension/period ke baare mein baat karni hai?';
      }
      if (isPain) {
        return 'Sakhi yahan hai. Period pain mein warm water, lower abdomen par heat, aur gentle rest help kar sakte hain. Pain bahut severe ho ya unusual lage to doctor ya ASHA worker se baat karein.';
      }
      if (isFood) {
        return 'Sakhi yahan hai. Simple Indian plate try karein: dal ya chana, ragi ya greens, rice/roti, curd suit kare to, aur paani. Perfect meal zaroori nahi.';
      }
      if (isMood) {
        return 'Sakhi yahan hai. Mood heavy lag raha ho to ek slow breath, thoda paani, aur kisi trusted person ko message karna help kar sakta hai.';
      }
    }

    if (language == 'manglish' || language == 'malayalam') {
      if (_hasAny(lower, ['hi', 'hello', 'hey'])) {
        return 'Sakhi ivide undu. Hi, innu engane undu? Just chat cheyyano, allenkil enthenkilum worry undo?';
      }
      if (isPain) {
        return 'Sakhi ivide undu. Period pain aanenkil warm water, lower abdomen-il heat, rest okke try cheyyam. Severe/unusual aanel doctor/ASHA worker-ode samsarikkuka.';
      }
      if (isFood) {
        return 'Sakhi ivide undu. Simple plate mathi: dal/chana, ragi/greens, rice/roti, curd suit cheyyunnenkil, vellam. Perfect meal venam ennu illa.';
      }
      if (isMood) {
        return 'Sakhi ivide undu. Mood heavy aanenkil slow breath, vellam, trusted aaya oralode samsarikkal help cheyyam.';
      }
    }

    final options = [
      'Hey, I am here. How are you feeling today? We can just chat, or you can tell me what is on your mind.',
      'Sakhi is here with you. Tell me one detail: pain, flow, mood, food, or cycle timing, and I will make the advice more specific.',
      'Sakhi is here with you. Cycle experiences can vary month to month. I can help you notice cycle pattern concerns and prepare gentle questions for a doctor or ASHA worker.',
      'Sakhi is here with you. Let us keep this practical: what changed today compared with your usual cycle day?',
    ];
    return options[variant];
  }

  bool _hasAny(String text, List<String> words) => words.any(text.contains);

  Future<void> disposeModel() async {
    await _model?.close();
    _model = null;
    _engine = SakhiEngine.localFallback;
  }
}
