import 'dart:convert';

class ScreeningRecord {
  const ScreeningRecord({
    this.id,
    required this.girlId,
    required this.riskScore,
    required this.riskTier,
    required this.color,
    required this.bmi,
    required this.anNeckScore,
    required this.anKnuckle,
    required this.periorbital,
    required this.hirsutism,
    required this.acneJawline,
    required this.menstrualScore,
    required this.menstrualText,
    required this.breakdown,
    required this.screenedAt,
    this.village,
    this.district,
  });

  final int? id;
  final String girlId;
  final int riskScore;
  final String riskTier;
  final String color;
  final double bmi;
  final double anNeckScore;
  final bool anKnuckle;
  final bool periorbital;
  final bool hirsutism;
  final bool acneJawline;
  final int menstrualScore;
  final String menstrualText;
  final Map<String, double> breakdown;
  final DateTime screenedAt;
  final String? village;
  final String? district;

  factory ScreeningRecord.fromDb(
    Map<String, Object?> row, {
    required String menstrualText,
    String? village,
    String? district,
  }) {
    return ScreeningRecord(
      id: row['id'] as int?,
      girlId: row['girl_id'] as String,
      riskScore: row['risk_score'] as int? ?? 0,
      riskTier: row['risk_tier'] as String? ?? 'Routine',
      color: row['color'] as String? ?? 'green',
      bmi: (row['bmi'] as num?)?.toDouble() ?? 0,
      anNeckScore: (row['an_neck_score'] as num?)?.toDouble() ?? 0,
      anKnuckle: (row['an_knuckle'] as int? ?? 0) == 1,
      periorbital: (row['periorbital'] as int? ?? 0) == 1,
      hirsutism: (row['hirsutism'] as int? ?? 0) == 1,
      acneJawline: (row['acne_jawline'] as int? ?? 0) == 1,
      menstrualScore: row['menstrual_score'] as int? ?? 0,
      menstrualText: menstrualText,
      breakdown: (jsonDecode(row['breakdown_json'] as String? ?? '{}')
              as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
      screenedAt: DateTime.tryParse(row['screened_at'] as String? ?? '') ??
          DateTime.now(),
      village: village,
      district: district,
    );
  }

  Map<String, Object?> toDb({
    required String encryptedMenstrualText,
    String? encryptedVillage,
    String? encryptedDistrict,
  }) {
    return {
      'girl_id': girlId,
      'risk_score': riskScore,
      'risk_tier': riskTier,
      'color': color,
      'bmi': bmi,
      'an_neck_score': anNeckScore,
      'an_knuckle': anKnuckle ? 1 : 0,
      'periorbital': periorbital ? 1 : 0,
      'hirsutism': hirsutism ? 1 : 0,
      'acne_jawline': acneJawline ? 1 : 0,
      'menstrual_score': menstrualScore,
      'menstrual_text_enc': encryptedMenstrualText,
      'breakdown_json': jsonEncode(breakdown),
      'screened_at': screenedAt.toIso8601String(),
      'village_enc': encryptedVillage,
      'district_enc': encryptedDistrict,
    };
  }

  String topMarker() {
    final positives = <String>[
      if (anNeckScore > .5) 'neck metabolic marker',
      if (anKnuckle) 'knuckle metabolic marker',
      if (periorbital) 'periorbital marker',
      if (hirsutism) 'hair-growth pattern',
      if (acneJawline) 'jawline acne pattern',
      if (menstrualScore > 0) 'cycle pattern',
    ];
    return positives.isEmpty ? 'routine monitoring' : positives.first;
  }
}
