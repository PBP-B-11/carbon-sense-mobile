import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef ProfileCity = ({String label, String token});

class ProfileApi {
  ProfileApi(this.client);

  final http.Client client;

  static final _baseUrl = Uri.parse(
    const String.fromEnvironment(
      'CARBON_SENSE_API_URL',
      defaultValue:
          'https://faishal-falih-carbon-sense.pws.cs.ui.ac.id/api/v1/',
    ),
  );

  Future<List<ProfileCity>> searchCities(String query) async {
    final response = await request(
      'GET',
      'profile/cities/',
      query: {'q': query},
    );
    return [
      for (final city in response['results'] as List)
        (label: city['label'] as String, token: city['token'] as String),
    ];
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    String? token,
    Map<String, Object>? body,
    Map<String, String>? query,
  }) async {
    final uri = _baseUrl.resolve(path).replace(queryParameters: query);
    final request = http.Request(method, uri)
      ..followRedirects = false
      ..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Token $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }

    try {
      final response = await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 204) return {};
      if (response.statusCode == 401 && token != null) {
        throw const ProfileApiException(
          'Sesi berakhir. Silakan masuk lagi.',
          401,
        );
      }
      if (response.statusCode >= 500 || response.statusCode < 200) {
        throw const ProfileApiException(
          'Server sedang tidak tersedia. Coba lagi.',
        );
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) throw const FormatException();
      if (response.statusCode >= 300) {
        final messages = data.values
            .expand<Object?>((value) => value is List ? value : [value])
            .whereType<String>()
            .join('\n');
        throw ProfileApiException(
          messages.isEmpty ? 'Permintaan gagal. Coba lagi.' : messages,
          response.statusCode,
        );
      }
      return data;
    } on http.ClientException {
      throw const ProfileApiException(
        'Koneksi gagal. Periksa internet dan coba lagi.',
      );
    } on TimeoutException {
      throw const ProfileApiException(
        'Server terlalu lama merespons. Coba lagi.',
      );
    } on FormatException {
      throw const ProfileApiException('Respons server tidak dapat dibaca.');
    }
  }
}

class ProfileApiException implements Exception {
  const ProfileApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;
}
