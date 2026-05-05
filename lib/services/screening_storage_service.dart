import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../db/models/screening_record.dart';
import '../providers/asha_screening_provider.dart';
import 'risk_engine.dart';
import 'security_service.dart';

class ScreeningStorageService {
  Future<void> saveScreening(RiskResult result, ScreeningState state) async {
    final db = await DatabaseHelper.instance.database;
    final record = ScreeningRecord(
      girlId: result.girlId,
      riskScore: result.score,
      riskTier: result.tier,
      color: result.color,
      bmi: state.bmi ?? 0,
      anNeckScore: state.anNeckScore,
      anKnuckle: state.anKnuckle,
      periorbital: state.periorbital,
      hirsutism: state.hirsutism,
      acneJawline: state.acneJawline,
      menstrualScore: state.menstrualScore,
      menstrualText: state.menstrualText,
      breakdown: result.breakdown,
      screenedAt: result.screenedAt,
    );
    await db.insert(
      'screening_records',
      record.toDb(
        encryptedMenstrualText:
            await SecurityService.instance.encrypt(record.menstrualText),
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScreeningRecord>> getHistory() async {
    final rows = await (await DatabaseHelper.instance.database).query(
      'screening_records',
      orderBy: 'screened_at DESC',
    );
    return Future.wait(rows.map((row) async {
      return ScreeningRecord.fromDb(
        row,
        menstrualText: row['menstrual_text_enc'] == null
            ? ''
            : await SecurityService.instance
                .decrypt(row['menstrual_text_enc'] as String),
        village: row['village_enc'] == null
            ? null
            : await SecurityService.instance
                .decrypt(row['village_enc'] as String),
        district: row['district_enc'] == null
            ? null
            : await SecurityService.instance
                .decrypt(row['district_enc'] as String),
      );
    }));
  }

  Future<void> deleteAll() async {
    await (await DatabaseHelper.instance.database).delete('screening_records');
  }

  Future<String> exportEncryptedCsv(String password) async {
    final records = await getHistory();
    final csv = StringBuffer(
      'girl_id,risk_score,risk_tier,bmi,menstrual_score,screened_at\n',
    );
    for (final r in records) {
      csv.writeln(
        '${r.girlId},${r.riskScore},${r.riskTier},${r.bmi.toStringAsFixed(1)},${r.menstrualScore},${r.screenedAt.toIso8601String()}',
      );
    }
    final key = sha256.convert(utf8.encode(password)).bytes;
    final bytes = utf8.encode(csv.toString());
    final encrypted = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ key[i % key.length],
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/asmita_screening_export_${DateTime.now().millisecondsSinceEpoch}.csv.enc',
    );
    await file.writeAsBytes(encrypted, flush: true);
    return file.path;
  }
}
