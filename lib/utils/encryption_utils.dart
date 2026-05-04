import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

class EncryptionUtils {
  static final _algorithm = AesGcm.with256bits();
  static final _random = Random.secure();

  static List<int> randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));

  static Future<String> encrypt(String plaintext, List<int> keyBytes) async {
    if (plaintext.isEmpty) return '';
    final secretKey = SecretKey(keyBytes);
    final nonce = randomBytes(12);
    final box = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );
    return base64Encode([...box.nonce, ...box.mac.bytes, ...box.cipherText]);
  }

  static Future<String> decrypt(String ciphertext, List<int> keyBytes) async {
    if (ciphertext.isEmpty) return '';
    final bytes = base64Decode(ciphertext);
    final nonce = bytes.sublist(0, 12);
    final mac = Mac(bytes.sublist(12, 28));
    final encrypted = bytes.sublist(28);
    final clear = await _algorithm.decrypt(
      SecretBox(encrypted, nonce: nonce, mac: mac),
      secretKey: SecretKey(keyBytes),
    );
    return utf8.decode(clear);
  }
}
