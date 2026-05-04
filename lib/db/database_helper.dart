import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../services/security_service.dart';
import 'models/chat_message.dart';
import 'models/cycle_entry.dart';
import 'models/daily_log.dart';
import 'models/user_profile.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static final _date = DateFormat('yyyy-MM-dd');
  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'asmita.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE user_profile(id INTEGER PRIMARY KEY, name_enc TEXT, date_of_birth TEXT, avg_cycle_length INTEGER DEFAULT 28, period_duration INTEGER DEFAULT 5, is_irregular INTEGER DEFAULT 0, life_stage TEXT DEFAULT "menstruating", suspects_pcos TEXT DEFAULT "not_sure", language TEXT DEFAULT "english", discreet_mode INTEGER DEFAULT 0, created_at TEXT)',
        );
        await db.execute(
          'CREATE TABLE cycle_entries(id INTEGER PRIMARY KEY, start_date TEXT NOT NULL, end_date TEXT, cycle_length INTEGER, period_length INTEGER, notes_enc TEXT, created_at TEXT)',
        );
        await db.execute(
          'CREATE TABLE daily_logs(id INTEGER PRIMARY KEY, date TEXT NOT NULL UNIQUE, flow_level INTEGER, mood TEXT, energy_level INTEGER, pain_locations TEXT, pain_intensity INTEGER, symptoms TEXT, notes_enc TEXT, temperature REAL, created_at TEXT)',
        );
        await db.execute(
          'CREATE TABLE symptoms(id INTEGER PRIMARY KEY, name TEXT, category TEXT, icon TEXT)',
        );
        await db.execute(
          'CREATE TABLE chat_messages(id INTEGER PRIMARY KEY, content_enc TEXT, role TEXT, timestamp TEXT, session_id TEXT)',
        );
        await db.execute(
          'CREATE TABLE app_settings(key TEXT PRIMARY KEY, value_enc TEXT)',
        );
        await _seedSymptoms(db);
      },
    );
  }

  Future<void> _seedSymptoms(Database db) async {
    final rows = [
      ['Cramps', 'body', 'waves'],
      ['Bloating', 'body', 'circle'],
      ['Headache', 'body', 'headphones'],
      ['Tender breasts', 'body', 'heart'],
      ['Acne', 'skin', 'sparkles'],
      ['Cravings', 'food', 'cookie'],
      ['Low mood', 'mood', 'cloud'],
      ['Anxiety', 'mood', 'wind'],
      ['Back pain', 'body', 'activity'],
    ];
    for (final r in rows) {
      await db.insert('symptoms', {
        'name': r[0],
        'category': r[1],
        'icon': r[2],
      });
    }
  }

  Future<UserProfile?> getProfile() async {
    final rows = await (await database).query('user_profile', limit: 1);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return UserProfile(
      id: r['id'] as int?,
      name: await _dec(r['name_enc']),
      dateOfBirth: await _dec(r['date_of_birth']),
      avgCycleLength: r['avg_cycle_length'] as int? ?? 28,
      periodDuration: r['period_duration'] as int? ?? 5,
      isIrregular: (r['is_irregular'] as int? ?? 0) == 1,
      lifeStage: r['life_stage'] as String? ?? 'menstruating',
      suspectsCyclePatternConcerns: r['suspects_pcos'] as String? ?? 'not_sure',
      language: r['language'] as String? ?? 'english',
      discreetMode: (r['discreet_mode'] as int? ?? 0) == 1,
      createdAt:
          DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final db = await database;
    final row = {
      'id': profile.id ?? 1,
      'name_enc': await _enc(profile.name),
      'date_of_birth': await _enc(profile.dateOfBirth),
      'avg_cycle_length': profile.avgCycleLength,
      'period_duration': profile.periodDuration,
      'is_irregular': profile.isIrregular ? 1 : 0,
      'life_stage': profile.lifeStage,
      'suspects_pcos': profile.suspectsCyclePatternConcerns,
      'language': profile.language,
      'discreet_mode': profile.discreetMode ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    };
    await db.insert(
      'user_profile',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CycleEntry>> cycles() async {
    final rows = await (await database).query(
      'cycle_entries',
      orderBy: 'start_date ASC',
    );
    return rows
        .map(
          (r) => CycleEntry(
            id: r['id'] as int?,
            startDate: DateTime.parse(r['start_date'] as String),
            endDate: DateTime.tryParse(r['end_date'] as String? ?? ''),
            cycleLength: r['cycle_length'] as int?,
            periodLength: r['period_length'] as int?,
            createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> insertCycle(CycleEntry entry) async {
    await (await database).insert('cycle_entries', {
      'start_date': _date.format(entry.startDate),
      'end_date': entry.endDate == null ? null : _date.format(entry.endDate!),
      'cycle_length': entry.cycleLength,
      'period_length': entry.periodLength,
      'notes_enc': await _enc(entry.notes),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<DailyLog>> logs() async {
    final rows = await (await database).query(
      'daily_logs',
      orderBy: 'date DESC',
    );
    return Future.wait(
      rows.map(
        (r) async => DailyLog(
          id: r['id'] as int?,
          date: DateTime.parse(r['date'] as String),
          flowLevel: r['flow_level'] as int? ?? 0,
          mood: r['mood'] as String?,
          energyLevel: r['energy_level'] as int?,
          painLocations: List<String>.from(
            jsonDecode(r['pain_locations'] as String? ?? '[]'),
          ),
          painIntensity: r['pain_intensity'] as int? ?? 0,
          symptoms: List<String>.from(
            jsonDecode(r['symptoms'] as String? ?? '[]'),
          ),
          notes: await _dec(r['notes_enc']),
          temperature: r['temperature'] as double?,
          createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ??
              DateTime.now(),
        ),
      ),
    );
  }

  Future<void> upsertLog(DailyLog log) async {
    await (await database).insert(
        'daily_logs',
        {
          'date': _date.format(log.date),
          'flow_level': log.flowLevel,
          'mood': log.mood,
          'energy_level': log.energyLevel,
          'pain_locations': jsonEncode(log.painLocations),
          'pain_intensity': log.painIntensity,
          'symptoms': jsonEncode(log.symptoms),
          'notes_enc': await _enc(log.notes),
          'temperature': log.temperature,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChatMessage>> chatMessages(String sessionId) async {
    final rows = await (await database).query(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return Future.wait(
      rows.map(
        (r) async => ChatMessage(
          id: r['id'] as int?,
          content: await _dec(r['content_enc']) ?? '',
          role: r['role'] as String? ?? 'user',
          timestamp: DateTime.parse(r['timestamp'] as String),
          sessionId: r['session_id'] as String,
        ),
      ),
    );
  }

  Future<void> insertChat(ChatMessage message) async {
    await (await database).insert('chat_messages', {
      'content_enc': await _enc(message.content),
      'role': message.role,
      'timestamp': message.timestamp.toIso8601String(),
      'session_id': message.sessionId,
    });
  }

  Future<void> clearChat() async => (await database).delete('chat_messages');
  Future<String?> _dec(Object? value) async => value == null || value == ''
      ? null
      : SecurityService.instance.decrypt(value as String);
  Future<String?> _enc(String? value) async {
    if (value == null || value.isEmpty) return '';
    return SecurityService.instance.encrypt(value);
  }
}
