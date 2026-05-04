import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class NetworkPrivacyService {
  const NetworkPrivacyService();

  Future<String> query(
    String url, {
    Map<String, String>? params,
    bool roundCoordinates = true,
  }) async {
    final base = Uri.parse(url);
    final sanitized = <String, String>{};
    (params ?? {}).forEach((key, value) {
      sanitized[key] = roundCoordinates && (key == 'lat' || key == 'lon')
          ? _round(value)
          : value;
    });
    final uri = base.replace(
      queryParameters: {...base.queryParameters, ...sanitized},
    );
    final response = await http.get(uri, headers: const {
      'User-Agent': 'Mozilla/5.0'
    }).timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw NetworkPrivacyException('Request failed');
    return response.body;
  }

  Future<void> downloadFile(
    String url,
    File destination, {
    void Function(double progress)? onProgress,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url))
        ..headers.addAll(const {'User-Agent': 'Mozilla/5.0'});
      final response =
          await client.send(request).timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const NetworkPrivacyException('Download failed');
      }

      await destination.parent.create(recursive: true);
      final sink = destination.openWrite();
      var received = 0;
      final total = response.contentLength;
      try {
        await for (final chunk
            in response.stream.timeout(const Duration(minutes: 12))) {
          received += chunk.length;
          sink.add(chunk);
          if (total != null && total > 0) {
            onProgress?.call((received / total).clamp(0, 1));
          }
        }
      } finally {
        await sink.close();
      }
      onProgress?.call(1);
    } on TimeoutException {
      throw const NetworkPrivacyException('Download timed out');
    } finally {
      client.close();
    }
  }

  String _round(String value) {
    final number = double.tryParse(value);
    if (number == null) return value;
    return number.toStringAsFixed(2);
  }
}

class NetworkPrivacyException implements Exception {
  const NetworkPrivacyException(this.message);
  final String message;
}
