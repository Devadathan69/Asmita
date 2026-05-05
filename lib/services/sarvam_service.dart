import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SarvamService {
  SarvamService({FlutterSecureStorage storage = const FlutterSecureStorage()})
      : _storage = storage;

  final FlutterSecureStorage _storage;

  static const languageCodes = {
    'malayalam': 'ml-IN',
    'hindi': 'hi-IN',
    'english': 'en-IN',
    'manglish': 'en-IN',
  };

  Future<bool> get isConfigured async {
    final key = await _storage.read(key: 'sarvam_api_key');
    return key != null && key.trim().isNotEmpty;
  }

  Future<String?> transcribeAudio({
    required String audioFilePath,
    required String languageCode,
  }) async {
    final key = await _storage.read(key: 'sarvam_api_key');
    if (key == null || key.trim().isEmpty) return null;
    final file = File(audioFilePath);
    if (!file.existsSync() || file.lengthSync() == 0) return null;
    return null;
  }
}
