import 'dart:async';
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
