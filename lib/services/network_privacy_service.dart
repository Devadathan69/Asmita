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
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkPrivacyException(
        'Request failed',
        statusCode: response.statusCode,
      );
    }
    return response.body;
  }

  Future<void> downloadFile(
    String url,
    File destination, {
    void Function(double progress)? onProgress,
    void Function(int receivedBytes, int? totalBytes)? onBytesProgress,
    bool Function()? shouldCancel,
    bool rejectHtmlContent = false,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url))
        ..headers.addAll(const {'User-Agent': 'Mozilla/5.0'});
      final response =
          await client.send(request).timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = response.statusCode == 401 || response.statusCode == 403
            ? 'Model download is not public. Please use a public model URL or place the model file in assets/models.'
            : 'Download failed';
        throw NetworkPrivacyException(
          message,
          statusCode: response.statusCode,
        );
      }
      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (rejectHtmlContent &&
          (contentType.contains('text/html') ||
              contentType.contains('application/xhtml'))) {
        throw const NetworkPrivacyException(
          'Download returned a web page instead of a model file',
        );
      }

      await destination.parent.create(recursive: true);
      final sink = destination.openWrite();
      var received = 0;
      final total = response.contentLength;
      try {
        await for (final chunk
            in response.stream.timeout(const Duration(minutes: 12))) {
          if (shouldCancel?.call() == true) {
            throw const NetworkPrivacyException('Download cancelled');
          }
          received += chunk.length;
          sink.add(chunk);
          onBytesProgress?.call(received, total);
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
  const NetworkPrivacyException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      statusCode == null ? message : '$message (HTTP $statusCode)';
}
