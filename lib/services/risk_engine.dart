import 'dart:math';

import 'package:uuid/uuid.dart';

class RiskResult {
  const RiskResult({
    required this.score,
    required this.tier,
    required this.action,
    required this.color,
    required this.displayMessage,
    required this.breakdown,
    required this.girlId,
    required this.screenedAt,
  });

  final int score;
  final String tier;
  final String action;
  final String color;
  final String displayMessage;
  final Map<String, double> breakdown;
  final String girlId;
  final DateTime screenedAt;
}

class MenstrualFeatures {
  const MenstrualFeatures({
    this.amenorrhea = false,
    this.amenorrheaMonths,
    this.cycleDays,
    this.irregular = false,
  });

  final bool amenorrhea;
  final int? amenorrheaMonths;
  final int? cycleDays;
  final bool irregular;
}

class MenstrualScore {
  const MenstrualScore({
    required this.score,
    required this.detected,
    required this.summary,
    required this.features,
  });

  final int score;
  final String detected;
  final String summary;
  final MenstrualFeatures features;
}

class MenstrualScorer {
  MenstrualScore analyze(String text) {
    final source = text.toLowerCase();
    final days = _numberNear(source, [
      'day',
      'days',
      'ദിവസം',
      'दिन',
    ]);
    final months = _numberNear(source, [
      'month',
      'months',
      'മാസം',
      'महीने',
    ]);
    final everyMonths =
        RegExp(r'every\s+(\d+)\s+months?').firstMatch(source)?.group(1);
    final everyMonthValue =
        everyMonths == null ? null : int.tryParse(everyMonths);
    final irregular = _irregularKeywords.any(source.contains);

    if ((months ?? 0) >= 3 ||
        source.contains('no period') ||
        source.contains('missed')) {
      return MenstrualScore(
        score: 25,
        detected: 'amenorrhea',
        summary: 'No cycle for 3 or more months',
        features: MenstrualFeatures(
          amenorrhea: true,
          amenorrheaMonths: months,
          cycleDays: days,
          irregular: true,
        ),
      );
    }

    if ((days ?? 0) > 35 || (everyMonthValue ?? 0) >= 2) {
      return MenstrualScore(
        score: 18,
        detected: 'oligomenorrhea',
        summary: 'Cycle gap appears longer than 35 days',
        features: MenstrualFeatures(cycleDays: days, irregular: true),
      );
    }

    if (irregular) {
      return MenstrualScore(
        score: 10,
        detected: 'irregular',
        summary: 'Irregular cycle pattern mentioned',
        features: MenstrualFeatures(cycleDays: days, irregular: true),
      );
    }

    if (days != null && days >= 21 && days <= 35) {
      return MenstrualScore(
        score: 0,
        detected: 'regular',
        summary: 'Cycle range appears routine',
        features: MenstrualFeatures(cycleDays: days),
      );
    }

    return const MenstrualScore(
      score: 0,
      detected: 'regular',
      summary: 'No cycle concern pattern found',
      features: MenstrualFeatures(),
    );
  }

  int? _numberNear(String text, List<String> words) {
    for (final word in words) {
      final before = RegExp('(\\d+)\\s*$word').firstMatch(text);
      if (before != null) return int.tryParse(before.group(1)!);
      final after = RegExp('$word\\s*(\\d+)').firstMatch(text);
      if (after != null) return int.tryParse(after.group(1)!);
    }
    return null;
  }

  static const _irregularKeywords = [
    'ക്രമം ഇല്ല',
    'ക്രമക്കേട്',
    'വൈകി',
    'ചിലപ്പോൾ',
    'ഒന്നിടവിട്ട്',
    'ക്രമം തെറ്റ',
    'अनियमित',
    'कभी-कभी',
    'देर से',
    'हर महीने नहीं',
    'ठीक नहीं',
    'irregular',
    'sometimes',
    'late',
    'delayed',
    'not every month',
    'skip',
    'missed',
    'no period',
    "don't get",
  ];
}

class RiskEngine {
  RiskResult compute({
    required double anNeckScore,
    required bool anKnuckle,
    required double anKnuckleConf,
    required bool periorbital,
    required double periorbitalConf,
    required bool hirsutism,
    required double hirsutismConf,
    required bool acneJawline,
    required int menstrualScore,
    required double bmi,
    required bool suddenOnset,
  }) {
    final bmiMod = bmi < 25 ? 1.5 : 0.8;
    final neckPts = min((anNeckScore / 1.0) * 15 * bmiMod, 15).toDouble();
    var knucklePts = 0.0;
    if (anKnuckle) {
      knucklePts = anNeckScore > 0.5 ? 15 : 5;
    }
    final periPts = periorbital ? periorbitalConf * 10 : 0.0;
    final hirsPts = hirsutism ? hirsutismConf * 5 : 0.0;
    final menstrualPts = menstrualScore.toDouble();
    final acnePts = acneJawline ? 10.0 : 0.0;
    final onsetPts = suddenOnset ? 5.0 : 0.0;
    final score = min(
      (neckPts +
              knucklePts +
              periPts +
              hirsPts +
              menstrualPts +
              acnePts +
              onsetPts)
          .round(),
      85,
    );

    final tier = _tier(score);
    final action = _action(score);
    final color = _color(score);
    return RiskResult(
      score: score,
      tier: tier,
      action: action,
      color: color,
      displayMessage: score <= 20
          ? 'Routine monitoring — rescreen in 12 months'
          : 'Metabolic/hormonal screening recommended — $action',
      breakdown: {
        'AN Neck': neckPts,
        'AN Knuckle': knucklePts,
        'Periorbital': periPts,
        'Hirsutism': hirsPts,
        'Menstrual': menstrualPts,
        'Acne Pattern': acnePts,
        'Sudden Onset': onsetPts,
      },
      girlId: const Uuid().v4(),
      screenedAt: DateTime.now(),
    );
  }

  String _tier(int score) {
    if (score <= 20) return 'Routine';
    if (score <= 40) return 'Metabolic';
    if (score <= 60) return 'Hormonal';
    return 'Urgent';
  }

  String _action(int score) {
    if (score <= 20) return 'Rescreen in 12 months';
    if (score <= 40) return 'PHC visit within 1 month';
    if (score <= 60) return 'PHC within 2 weeks';
    return 'PHC within 48 hrs';
  }

  String _color(int score) {
    if (score <= 20) return 'green';
    if (score <= 40) return 'yellow';
    if (score <= 60) return 'orange';
    return 'red';
  }
}
