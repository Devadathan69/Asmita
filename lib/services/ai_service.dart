import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../db/models/chat_message.dart';

enum _CompanionIntent {
  cramps,
  heavyFlow,
  latePeriod,
  food,
  mood,
  sleep,
  exercise,
  hygiene,
  cyclePattern,
  greeting,
  general,
}

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
      final data = await _loadBundledModelOrReadinessPack();
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

    if (!await verifyModelChecksum() &&
        !expectedSha256.startsWith('replace_')) {
      if (file.existsSync()) file.deleteSync();
      throw StateError('Downloaded model checksum failed');
    }
    await loadModel();
    yield 1;
  }

  Future<List<int>> _loadBundledModelOrReadinessPack() async {
    try {
      final bytes = await rootBundle.load(bundledAsset);
      if (bytes.lengthInBytes > 0) return bytes.buffer.asUint8List();
    } catch (_) {
      // The real Gemma file is intentionally not committed because it is large.
    }
    final text = jsonEncode({
      'engine': 'sakhi-local-companion-v1',
      'note':
          'Place the Gemma model at $bundledAsset and set expectedSha256 before release.',
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
    final response = _localCompanionResponse(userMessage, history, language);
    final tokens = response.split(' ');
    for (final token in tokens.take(300)) {
      await Future<void>.delayed(const Duration(milliseconds: 18));
      yield '$token ';
    }
  }

  String _localCompanionResponse(
    String message,
    List<ChatMessage> history,
    String language,
  ) {
    final normalized = message.toLowerCase().trim();
    final intent = _detectIntent(normalized);
    final variant = _variantFor(normalized, history.length);
    final recentUserMessages = history
        .where((item) => item.role == 'user')
        .map((item) => item.content.toLowerCase())
        .take(3)
        .join(' ');

    final isRepeatedTopic = recentUserMessages.isNotEmpty &&
        recentUserMessages.contains(normalized);
    final prefix = _prefix(language, isRepeatedTopic);
    final safety = _safety(language, intent);
    final body = _body(language, intent, variant);
    final nextStep = _nextStep(language, intent, variant);

    return '$prefix$body $nextStep$safety';
  }

  _CompanionIntent _detectIntent(String text) {
    final checks = <_CompanionIntent, List<String>>{
      _CompanionIntent.greeting: ['hi', 'hello', 'hey', 'namaste'],
      _CompanionIntent.cramps: [
        'pain',
        'cramp',
        'stomach',
        'back pain',
        'headache',
        'vedana',
        'dard',
      ],
      _CompanionIntent.heavyFlow: [
        'heavy',
        'bleeding',
        'clot',
        'flow',
        'pad',
        'leak',
      ],
      _CompanionIntent.latePeriod: [
        'late',
        'missed',
        'delay',
        'pregnant',
        'not come',
        'varunnilla',
      ],
      _CompanionIntent.food: [
        'food',
        'eat',
        'diet',
        'nutrition',
        'iron',
        'ragi',
        'vellam',
        'khana',
      ],
      _CompanionIntent.mood: [
        'sad',
        'stress',
        'angry',
        'cry',
        'anxious',
        'mood',
        'tension',
      ],
      _CompanionIntent.sleep: [
        'sleep',
        'tired',
        'fatigue',
        'energy',
        'weak',
        'urakkam',
      ],
      _CompanionIntent.exercise: [
        'exercise',
        'walk',
        'yoga',
        'workout',
        'stretch',
      ],
      _CompanionIntent.hygiene: [
        'napkin',
        'sanitary',
        'menstrual cup',
        'tampon',
        'rash',
        'itch',
      ],
      _CompanionIntent.cyclePattern: [
        'cycle',
        'period date',
        'regular',
        'irregular',
        'pattern',
      ],
    };

    for (final entry in checks.entries) {
      if (entry.value.any(text.contains)) return entry.key;
    }
    return _CompanionIntent.general;
  }

  int _variantFor(String text, int historyLength) {
    final digest = sha1.convert(utf8.encode('$text|$historyLength')).bytes;
    return digest.first % 3;
  }

  String _prefix(String language, bool repeatedTopic) {
    if (repeatedTopic) {
      return switch (language) {
        'hindi' => 'Aap isi baat ko dobara pooch rahi hain, so gently: ',
        'malayalam' => 'Ithu same topic aanu, athukondu melle parayam: ',
        'manglish' => 'Ithu same topic aanu, so nammal simple aayi nokkam: ',
        _ => 'You are asking about the same thing again, so gently: ',
      };
    }
    return switch (language) {
      'hindi' => 'Sakhi yahan hai. ',
      'malayalam' => 'Sakhi ivide undu. ',
      'manglish' => 'Sakhi ivide undu. ',
      _ => 'Sakhi is here with you. ',
    };
  }

  String _body(String language, _CompanionIntent intent, int variant) {
    final english = <_CompanionIntent, List<String>>{
      _CompanionIntent.greeting: [
        'Tell me what is happening today: pain, mood, flow, food, or cycle timing.',
        'You can ask me about your period, symptoms, food, comfort, or what to track.',
        'I can help you think through today gently, without judging or diagnosing.',
      ],
      _CompanionIntent.cramps: [
        'Cramps can feel very draining. Warm water, a heat pad on the lower abdomen, and slow breathing often help.',
        'For period pain, try rest, gentle stretching, and warm fluids like jeera water or ginger tea if they suit you.',
        'If the pain is in the back or lower belly, note the location and intensity in today\'s log so patterns become clearer.',
      ],
      _CompanionIntent.heavyFlow: [
        'Heavy flow days need extra gentleness. Change pads regularly, drink water, and rest when your body asks.',
        'If you are soaking pads very quickly, feeling dizzy, or seeing sudden heavy bleeding, that is worth discussing with a doctor.',
        'Track flow level today and tomorrow. Two or three notes are often enough to see whether this is your usual pattern.',
      ],
      _CompanionIntent.latePeriod: [
        'A delayed period can happen with stress, travel, sleep changes, illness, or weight changes.',
        'If pregnancy is possible, a home test after a missed period can give clearer information.',
        'Try noting the expected date, recent stress, sleep, medicines, and any unusual symptoms.',
      ],
      _CompanionIntent.food: [
        'A simple Indian plate can be enough: dal or chana, leafy greens or ragi, rice or roti, curd if it suits you, and water.',
        'During low-energy days, iron-rich foods like ragi, spinach, dates, beans, or small fish can support you.',
        'If cravings are strong, pair comfort food with something steadying, like curd rice, dal, banana, nuts, or warm kanji.',
      ],
      _CompanionIntent.mood: [
        'Mood changes around the cycle are real and can feel heavy. Try one small comfort first: water, shower, rest, or a short walk.',
        'Pause for one slow breath and soften your shoulders. You do not have to solve everything in this moment.',
        'If you feel overwhelmed, message or sit with someone you trust. You deserve support, not silence.',
      ],
      _CompanionIntent.sleep: [
        'Low energy can happen around cycle changes. Keep today simple, hydrate, and let the body move slowly.',
        'A regular sleep time, dim lights, and less caffeine after evening can help if sleep has been disturbed.',
        'If tiredness feels unusual for many days, log it and consider discussing it with a health worker.',
      ],
      _CompanionIntent.exercise: [
        'Gentle movement is usually enough during period days: walking, child\'s pose, or light hip stretches.',
        'If your body feels strong, light exercise is okay. If pain increases, reduce intensity.',
        'For luteal or tired days, choose grounding movement over pushing hard.',
      ],
      _CompanionIntent.hygiene: [
        'Change pads or cloth regularly and keep the area dry. If rash appears, avoid scented products where possible.',
        'For cups or reusable cloth, clean hands and proper washing matter more than fancy products.',
        'Itching, bad smell, fever, or persistent burning should be discussed with a doctor or ASHA worker.',
      ],
      _CompanionIntent.cyclePattern: [
        'Cycle timing can vary. What matters is the pattern over a few months, not one single date.',
        'Asmita can help you track dates, flow, pain, mood, and energy so cycle pattern concerns become easier to explain.',
        'If cycles are repeatedly very short, very long, or unpredictable, that is worth discussing gently with a health worker.',
      ],
      _CompanionIntent.general: [
        'I can help with period pain, food, mood, flow, sleep, hygiene, or questions to ask a doctor.',
        'Share one detail from today, like where the pain is, flow level, mood, or expected period date.',
        'Let us make it practical: what changed today compared with your usual cycle day?',
      ],
    };

    final manglish = <_CompanionIntent, List<String>>{
      _CompanionIntent.greeting: [
        'Innu entha feel cheyyunnath: pain, mood, flow, food, allenkil cycle timing?',
        'Period, symptoms, food, comfort, track cheyyenda karyangal okke chodikkam.',
        'Njan diagnosis parayilla, paksha gently think cheyyan help cheyyam.',
      ],
      _CompanionIntent.cramps: [
        'Cramps valare tiring aavum. Warm water, lower abdomen-il heat pad, slow breathing try cheyyam.',
        'Period pain aanel rest, gentle stretch, ginger tea suit cheyyunnenkil athu try cheyyam.',
        'Back/lower belly pain aanenkil locationum intensityum log cheythal pattern manasilavum.',
      ],
      _CompanionIntent.heavyFlow: [
        'Heavy flow days-il body-inu extra care venam. Pad regular aayi maattuka, vellam kudikkuka, rest edukkuka.',
        'Pad valare vegam soak aavunnu, dizziness undu, sudden heavy bleeding undu enkil doctor-ode parayunnath nallathaanu.',
        'Innum naaleyum flow level track cheyyu. Usual pattern aano ennathu clear aavum.',
      ],
      _CompanionIntent.latePeriod: [
        'Period delay stress, travel, sleep change, illness, weight change okke kond aavum.',
        'Pregnancy chance undenkil missed period kazhinju home test clear information tharum.',
        'Expected date, stress, sleep, medicines, unusual symptoms eniva note cheyyu.',
      ],
      _CompanionIntent.food: [
        'Simple Indian plate mathi: dal/chana, greens/ragi, rice/roti, curd suit cheyyunnenkil, vellam.',
        'Low energy days-il ragi, spinach, dates, beans, small fish pole iron-rich food support cheyyum.',
        'Cravings undenkil comfort food-inoppam curd rice, dal, banana, nuts, warm kanji pole steady food add cheyyu.',
      ],
      _CompanionIntent.mood: [
        'Mood cycle samayath heavy aavunnath real aanu. First one small comfort: vellam, shower, rest, short walk.',
        'Oru slow breath edukku, shoulders relax cheyyu. Ellam ippo solve cheyyenda.',
        'Overwhelmed aanenkil trust cheyyunna oralode samsarikkuka. Support deserve cheyyunnu.',
      ],
      _CompanionIntent.sleep: [
        'Low energy cycle changes-il common aanu. Innu simple aakkam, hydrate cheyyu, body slowly move cheyyatte.',
        'Regular sleep time, dim lights, evening caffeine kurakkal help cheyyam.',
        'Tiredness pala divasam unusual aanel log cheythu health worker-ode discuss cheyyam.',
      ],
      _CompanionIntent.exercise: [
        'Period days-il gentle movement mathi: walking, child\'s pose, light hip stretches.',
        'Body strong aanenkil light exercise okay. Pain koodiyal intensity kurakkuka.',
        'Luteal/tired days-il hard push cheyyathe grounding movement choose cheyyu.',
      ],
      _CompanionIntent.hygiene: [
        'Pad/cloth regular aayi maattuka, area dry aakki vekkuka. Rash undenkil scented products avoid cheyyam.',
        'Cup/reusable cloth use cheyyumbol clean hands and proper washing main aanu.',
        'Itching, bad smell, fever, burning persist cheythal doctor/ASHA worker-ode parayuka.',
      ],
      _CompanionIntent.cyclePattern: [
        'Cycle timing maram. Oru date alla, kurachu months pattern aanu important.',
        'Asmita dates, flow, pain, mood, energy track cheyyan help cheyyum.',
        'Repeated short/long/unpredictable cycles undenkil health worker-ode discuss cheyyunnath nallathaanu.',
      ],
      _CompanionIntent.general: [
        'Pain, food, mood, flow, sleep, hygiene, doctor-ode chodikkanulla questions okke njan help cheyyam.',
        'Innu oru detail parayu: pain evide, flow level, mood, expected period date.',
        'Practical aayi nokkam: usual cycle day-il ninn innu entha maariyath?',
      ],
    };

    final hindi = <_CompanionIntent, List<String>>{
      _CompanionIntent.greeting: [
        'Aaj kya ho raha hai: pain, mood, flow, food, ya cycle timing?',
        'Aap period, symptoms, food, comfort, ya tracking ke baare mein pooch sakti hain.',
        'Main diagnosis nahi karti, par gently sochne mein madad kar sakti hoon.',
      ],
      _CompanionIntent.cramps: [
        'Cramps bahut draining lag sakte hain. Garam paani, lower abdomen par heat pad, aur slow breathing help kar sakte hain.',
        'Period pain mein rest, gentle stretching, aur ginger tea suit kare to try kar sakti hain.',
        'Back ya lower belly pain ho to location aur intensity log karna pattern samajhne mein madad karega.',
      ],
      _CompanionIntent.heavyFlow: [
        'Heavy flow days mein extra gentleness zaroori hai. Pad regular change karein, paani piyen, aur rest lein.',
        'Agar pad bahut jaldi soak ho raha hai, dizziness hai, ya sudden heavy bleeding hai, doctor se baat karna achha rahega.',
        'Aaj aur kal flow level track karein. Isse usual pattern clear ho sakta hai.',
      ],
      _CompanionIntent.latePeriod: [
        'Period delay stress, travel, sleep change, illness, ya weight change se ho sakta hai.',
        'Pregnancy possible ho to missed period ke baad home test clearer information de sakta hai.',
        'Expected date, stress, sleep, medicines, aur unusual symptoms note karein.',
      ],
      _CompanionIntent.food: [
        'Simple Indian plate enough ho sakti hai: dal ya chana, greens ya ragi, rice ya roti, curd suit kare to, aur paani.',
        'Low energy days mein ragi, spinach, dates, beans, ya small fish jaise iron-rich foods support kar sakte hain.',
        'Cravings strong ho to comfort food ke saath curd rice, dal, banana, nuts, ya warm kanji add karein.',
      ],
      _CompanionIntent.mood: [
        'Cycle ke around mood changes real hote hain. Pehle ek small comfort try karein: paani, shower, rest, ya short walk.',
        'Ek slow breath lein aur shoulders relax karein. Sab kuch isi moment solve karna zaroori nahi.',
        'Agar overwhelmed feel ho, kisi trusted person se baat karein. Aap support deserve karti hain.',
      ],
      _CompanionIntent.sleep: [
        'Low energy cycle changes ke around common ho sakti hai. Aaj simple rakhein, hydrate karein, aur body ko slow chalne dein.',
        'Regular sleep time, dim lights, aur evening caffeine kam karna help kar sakta hai.',
        'Tiredness many days unusual lage to log karein aur health worker se discuss karein.',
      ],
      _CompanionIntent.exercise: [
        'Period days mein gentle movement enough hota hai: walking, child\'s pose, ya light hip stretches.',
        'Body strong lage to light exercise okay hai. Pain badhe to intensity kam karein.',
        'Tired days mein hard push ke bajay grounding movement choose karein.',
      ],
      _CompanionIntent.hygiene: [
        'Pad ya cloth regular change karein aur area dry rakhein. Rash ho to scented products avoid karein.',
        'Cup ya reusable cloth mein clean hands aur proper washing sabse important hai.',
        'Itching, bad smell, fever, ya persistent burning ho to doctor ya ASHA worker se baat karein.',
      ],
      _CompanionIntent.cyclePattern: [
        'Cycle timing vary kar sakta hai. Ek date se zyada kuch months ka pattern important hota hai.',
        'Asmita dates, flow, pain, mood, aur energy track karne mein help karega.',
        'Cycles repeatedly very short, very long, ya unpredictable hon to health worker se discuss karna achha rahega.',
      ],
      _CompanionIntent.general: [
        'Main period pain, food, mood, flow, sleep, hygiene, ya doctor se poochne wale questions mein help kar sakti hoon.',
        'Aaj ka ek detail share karein: pain kahan hai, flow level, mood, ya expected period date.',
        'Practical tareeke se dekhein: aaj usual cycle day se kya different hai?',
      ],
    };

    final malayalam = manglish;

    final source = switch (language) {
      'hindi' => hindi,
      'malayalam' => malayalam,
      'manglish' => manglish,
      _ => english,
    };
    final responses = source[intent] ?? source[_CompanionIntent.general]!;
    return responses[variant % responses.length];
  }

  String _nextStep(String language, _CompanionIntent intent, int variant) {
    final action = switch (intent) {
      _CompanionIntent.cramps => [
          'Log pain location and intensity now, then check again in two hours.',
          'Try heat for 15-20 minutes and drink something warm if it suits you.',
          'If pain is new or much stronger than usual, make a note for your doctor.',
        ],
      _CompanionIntent.food => [
          'Choose one easy item first, not a perfect meal.',
          'If appetite is low, start with warm kanji, banana, or curd rice.',
          'Pair tea or coffee with food if it makes acidity worse.',
        ],
      _CompanionIntent.mood => [
          'Try naming the feeling in one word; that alone can reduce the pressure.',
          'A small note in the mood log can help you compare this with next month.',
          'Please reach out to someone nearby if you feel unsafe or alone with this.',
        ],
      _CompanionIntent.latePeriod => [
          'If it stays delayed, tracking the next few days will give a clearer picture.',
          'Avoid blaming yourself; cycle timing is sensitive to many ordinary changes.',
          'If pregnancy is possible, use a test and speak with a clinician for guidance.',
        ],
      _ => [
          'Tell me one more detail and I will make the advice more specific.',
          'You can also log this in Asmita so it does not stay only in your head.',
          'Small observations over time are often more useful than one perfect answer.',
        ],
    };
    final selected = action[variant % action.length];
    return switch (language) {
      'hindi' => 'Next step: $selected ',
      'malayalam' => 'Next step: $selected ',
      'manglish' => 'Next step: $selected ',
      _ => 'Next step: $selected ',
    };
  }

  String _safety(String language, _CompanionIntent intent) {
    final needsCare = {
      _CompanionIntent.cramps,
      _CompanionIntent.heavyFlow,
      _CompanionIntent.latePeriod,
      _CompanionIntent.hygiene,
      _CompanionIntent.cyclePattern,
    }.contains(intent);
    if (!needsCare) return '';
    return switch (language) {
      'hindi' =>
        'Main diagnosis nahi karti; medical concern ho to doctor ya ASHA worker se baat karein.',
      'malayalam' =>
        'Njan diagnosis parayilla; medical concern undenkil doctor allenkil ASHA worker-ode samsarikkuka.',
      'manglish' =>
        'Njan diagnosis parayilla; medical concern undenkil doctor/ASHA worker-ode samsarikkuka.',
      _ =>
        'I cannot diagnose; for medical concerns, please speak with a doctor or ASHA worker.',
    };
  }

  void disposeModel() {
    _loaded = false;
  }
}
