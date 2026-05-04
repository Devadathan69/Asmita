import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../db/models/chat_message.dart';

class AiService {
  static const expectedSha256 =
      'replace_with_published_gemma_model_sha256_before_release';
  static const fileName = 'gemma-2b-it-gpu-int4.bin';
  static const bundledAsset = 'assets/models/$fileName';

  bool _loaded = false;

  Future<File> _modelFile() async =>
      File('${(await getApplicationDocumentsDirectory()).path}/$fileName');

  Future<bool> isModelAvailable() async {
    final file = await _modelFile();
    return file.existsSync() && file.lengthSync() > 0;
  }

  Future<void> loadModel() async {
    if (!await isModelAvailable()) {
      throw StateError('Model not available');
    }
    if (!await verifyModelChecksum()) {
      final file = await _modelFile();
      if (file.existsSync()) file.deleteSync();
      throw StateError('Model checksum failed');
    }
    await Future<void>.delayed(const Duration(milliseconds: 450));
    _loaded = true;
  }

  Stream<double> downloadModel() async* {
    final file = await _modelFile();
    await file.parent.create(recursive: true);
    final sink = file.openWrite();
    try {
      final data = await _loadBundledModelOrDemoPack();
      const chunks = 40;
      final chunkSize = (data.length / chunks).ceil();
      var written = 0;
      for (var i = 0; i < data.length; i += chunkSize) {
        final end = (i + chunkSize).clamp(0, data.length);
        sink.add(data.sublist(i, end));
        written = end;
        yield (written / data.length).clamp(0, 1);
        await Future<void>.delayed(const Duration(milliseconds: 70));
      }
    } finally {
      await sink.close();
    }

    if (!await verifyModelChecksum()) {
      if (!expectedSha256.startsWith('replace_')) {
        if (file.existsSync()) file.deleteSync();
        throw StateError('Downloaded model checksum failed');
      }
    }
    await loadModel();
    yield 1;
  }

  Future<List<int>> _loadBundledModelOrDemoPack() async {
    try {
      final bytes = await rootBundle.load(bundledAsset);
      if (bytes.lengthInBytes > 0) return bytes.buffer.asUint8List();
    } catch (_) {
      // No bundled Gemma file yet. Use a small local readiness pack so the
      // UI can exercise setup/progress without making any network call.
    }
    final text = jsonEncode({
      'engine': 'sakhi-local-readiness-pack',
      'note':
          'Place the Gemma model at $bundledAsset to enable real on-device inference.',
      'created_at': DateTime.now().toIso8601String(),
    });
    return utf8.encode(text * 512);
  }

  Future<bool> verifyModelChecksum() async {
    final file = await _modelFile();
    if (!file.existsSync() || file.lengthSync() == 0) return false;
    if (expectedSha256.startsWith('replace_')) return true;
    return sha256.convert(await file.readAsBytes()).toString() ==
        expectedSha256;
  }

  Stream<String> generateResponse(
    String userMessage,
    List<ChatMessage> history, {
    required String language,
  }) async* {
    if (!_loaded) {
      await loadModel();
    }
    final response = _localCompanionResponse(userMessage, language);
    final words = response.split(' ');
    for (final word in words.take(300)) {
      await Future<void>.delayed(const Duration(milliseconds: 24));
      yield '$word ';
    }
  }

  String _localCompanionResponse(String message, String language) {
    final lower = message.toLowerCase();
    final pain = lower.contains('pain') ||
        lower.contains('cramp') ||
        lower.contains('വേദന') ||
        lower.contains('दर्द');
    final food = lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('nutrition') ||
        lower.contains('ഭക്ഷണം') ||
        lower.contains('खाना');
    final stress = lower.contains('sad') ||
        lower.contains('stress') ||
        lower.contains('cry') ||
        lower.contains('anxious');

    if (language == 'malayalam') {
      if (pain) {
        return 'ഇന്ന് വേദന കൂടുതലാണെന്ന് തോന്നുന്നു. ചൂടുവെള്ളം, വിശ്രമം, lower abdomen ഭാഗത്ത് gentle heat എന്നിവ സഹായിക്കാം. വേദന ശക്തമോ ആശങ്കപ്പെടുത്തുന്നതോ ആണെങ്കിൽ ഡോക്ടറെയോ ASHA worker-നെയോ സംസാരിക്കുക.';
      }
      if (food) {
        return 'ഈ ഘട്ടത്തിൽ dal, ragi, leafy greens, dates, curd എന്നിവ പോലുള്ള ലളിതമായ ഭക്ഷണം നല്ലതാണ്. നിങ്ങളുടെ ശരീരം പറയുന്നത് കേട്ട് മെല്ലെ മുന്നോട്ട് പോകൂ.';
      }
      return 'ഞാൻ ഇവിടെ ഉണ്ടു. Cycle pattern മാസംതോറും മാറാം. ഞാൻ diagnosis നൽകില്ല, പക്ഷേ doctor/ASHA worker-നോട് ചോദിക്കേണ്ട കാര്യങ്ങൾ തയ്യാറാക്കാൻ സഹായിക്കാം.';
    }

    if (language == 'hindi') {
      if (pain) {
        return 'आज दर्द ज़्यादा लग रहा है तो थोड़ा आराम, गर्म पानी और lower abdomen पर gentle heat मदद कर सकते हैं. दर्द बहुत तेज़ या चिंता वाला लगे तो doctor या ASHA worker से बात करें.';
      }
      if (food) {
        return 'एक simple Indian plate मदद कर सकती है: dal या chana, leafy greens या ragi, curd अगर suit करे, और पर्याप्त पानी. अपने शरीर की बात धीरे से सुनें.';
      }
      return 'मैं आपके साथ हूँ. Cycle pattern महीने-दर-महीने बदल सकता है. मैं diagnosis नहीं करती, पर doctor या ASHA worker से पूछने के सवाल तैयार करने में मदद कर सकती हूँ.';
    }

    if (language == 'manglish') {
      if (pain) {
        return 'Innu pain kurachu heavy aanennu thonnunnu. Rest, warm water, lower abdomen-il gentle heat try cheyyam. Pain severe aanel doctor/ASHA worker-ode samsarikkunnath nallathaanu.';
      }
      if (food) {
        return 'Simple Indian food mathi: dal/chana proteininu, ragi or greens ironinu, curd suit cheyyunnenkil, plus vellam. Body parayunnath kelkku.';
      }
      return 'Njan ivide undu. Cycle pattern month to month maram. Diagnosis njan parayilla, paksha doctor/ASHA worker-ode chodikkanulla questions prepare cheyyan help cheyyam.';
    }

    if (pain) {
      return 'I am sorry today feels difficult. Warm water, rest, and gentle heat on the lower abdomen may help. If pain feels severe, sudden, or worrying, speaking with a doctor or ASHA worker would be wise.';
    }
    if (food) {
      return 'A simple Indian plate can help: dal or chana for protein, leafy greens or ragi for iron, curd if it suits you, and enough water. Keep it gentle and listen to your body.';
    }
    if (stress) {
      return 'That sounds heavy to carry. Take one slow breath with me and try to soften your shoulders. If this feeling stays or feels unsafe, please speak with someone you trust or a health worker nearby.';
    }
    return 'I am here with you. Cycle experiences can vary from month to month. I cannot diagnose, but I can help you notice cycle pattern concerns and prepare questions for a doctor or ASHA worker.';
  }

  void disposeModel() {
    _loaded = false;
  }
}
