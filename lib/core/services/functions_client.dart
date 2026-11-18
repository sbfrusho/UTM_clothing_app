import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_exception.dart';

/// Calls the HTTPS Cloud Functions in `functions/` with the user's Firebase
/// ID token. Server errors come back as `{error: "..."}` and are surfaced as
/// [AppException] with that message.
class FunctionsClient {
  FunctionsClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.functionsBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  bool get isConfigured => _baseUrl.isNotEmpty;

  Future<Map<String, dynamic>> call(
    String name,
    Map<String, Object?> body,
  ) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$_baseUrl/$name'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw AppException(
        'No connection. Please check your internet.',
        cause: e,
      );
    }
    Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      json = const {};
    }
    if (res.statusCode != 200) {
      throw AppException(
        json['error'] as String? ?? 'Something went wrong. Please try again.',
      );
    }
    return json;
  }
}
