import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/encryption_utils.dart';

class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'asmita_aes_key';
  static const _saltName = 'asmita_key_salt';
  static const _pinName = 'asmita_discreet_pin';
  static const _autoWipeName = 'asmita_auto_wipe';

  Future<String> generateEncryptionKey() async {
    final existing = await retrieveKey();
    if (existing != null) return existing;
    final salt = base64Encode(EncryptionUtils.randomBytes(32));
    await _storage.write(key: _saltName, value: salt);
    final seed =
        'asmita-device-bound-${DateTime.now().microsecondsSinceEpoch}-$salt';
    final digest = sha256.convert(utf8.encode(seed)).bytes;
    final key = base64Encode(digest);
    await storeKey(key);
    return key;
  }

  Future<void> storeKey(String key) =>
      _storage.write(key: _keyName, value: key);
  Future<String?> retrieveKey() => _storage.read(key: _keyName);

  Future<List<int>> _keyBytes() async =>
      base64Decode(await generateEncryptionKey());
  Future<String> encrypt(String plaintext) async =>
      EncryptionUtils.encrypt(plaintext, await _keyBytes());
  Future<String> decrypt(String ciphertext) async =>
      EncryptionUtils.decrypt(ciphertext, await _keyBytes());

  Future<void> setPin(String pin) async {
    final hash = sha256.convert(utf8.encode('asmita-pin-$pin')).toString();
    await _storage.write(key: _pinName, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinName);
    if (stored == null) return true;
    return stored == sha256.convert(utf8.encode('asmita-pin-$pin')).toString();
  }

  Future<void> setAutoWipe(bool enabled) =>
      _storage.write(key: _autoWipeName, value: enabled ? '1' : '0');
  Future<bool> autoWipeEnabled() async =>
      await _storage.read(key: _autoWipeName) == '1';

  Future<void> wipeAllData(Database db) async {
    for (final table in [
      'user_profile',
      'cycle_entries',
      'daily_logs',
      'symptoms',
      'chat_messages',
      'app_settings',
    ]) {
      await db.delete(table);
    }
    await _storage.deleteAll();
  }
}
