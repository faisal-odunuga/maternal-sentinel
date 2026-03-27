import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApiService {
  AuthApiService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<AuthApiResponse> verifyBvn(String bvn) async {
    final uri = Uri.parse('$baseUrl/v1/auth/verify-bvn');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bvn': bvn}),
    );

    dynamic decodedBody;
    try {
      decodedBody = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      decodedBody = null;
    }

    return AuthApiResponse(
      statusCode: response.statusCode,
      body: decodedBody,
      rawBody: response.body,
    );
  }
}

class AuthApiResponse {
  const AuthApiResponse({
    required this.statusCode,
    required this.body,
    required this.rawBody,
  });

  final int statusCode;
  final dynamic body;
  final String rawBody;
}
