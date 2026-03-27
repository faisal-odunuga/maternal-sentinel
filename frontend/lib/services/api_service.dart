import 'dart:convert';

import 'package:http/http.dart' as http;


class ApiService {
  ApiService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  // --- AUTH ---
  Future<ApiResponse> registerLegacyUser(Map<String, dynamic> data) => _post('/v1/auth/register', data);
  Future<ApiResponse> loginLegacyUser(Map<String, dynamic> data) => _post('/v1/auth/login', data);
  Future<ApiResponse> verifyBvn(String bvn) => _post('/v1/auth/verify-bvn', {'bvn': bvn});

  // --- MATERNAL AUTH ---
  Future<ApiResponse> verifyIdentity(Map<String, dynamic> data) => _post('/v1/auth/verify-identity', data);
  Future<ApiResponse> refreshSession(String refreshToken) => _post('/v1/auth/refresh-session', {'refresh_token': refreshToken});
  Future<ApiResponse> getClinicOfSession(String token) => _get('/v1/clinics/me', token: token);

  // --- PATIENTS ---
  Future<ApiResponse> registerPatient(Map<String, dynamic> data, {String? token}) => _post('/v1/patients/register', data, token: token);
  Future<ApiResponse> searchPatients(String query, {String? token}) => _get('/v1/patients/search?q=$query', token: token);
  Future<ApiResponse> getPatientProfile(String id, {String? token}) => _get('/v1/patients/$id/profile', token: token);
  Future<ApiResponse> getPatientTrends(String id, {String? token}) => _get('/v1/patients/$id/trends', token: token);

  // --- CASES ---
  Future<ApiResponse> batchUploadCases(List<Map<String, dynamic>> cases, {String? token}) => _post('/v1/sync/batch-upload', {'cases': cases}, token: token);
  Future<ApiResponse> getHighRiskQueue({String? token}) => _get('/v1/doctor/queue/high-risk', token: token);

  // --- PAYMENTS ---
  Future<ApiResponse> initializePayment(Map<String, dynamic> data, {String? token}) => _post('/v1/payments/initialize', data, token: token);
  Future<ApiResponse> paymentWebhook(Map<String, dynamic> data) => _post('/v1/payments/webhook', data);

  // --- NOTIFICATIONS ---
  Future<ApiResponse> sendSmsAlert(Map<String, dynamic> data, {String? token}) => _post('/v1/notifications/sms-alert', data, token: token);

  // --- SENTINEL ---
  Future<ApiResponse> startLiveAnemiaScan(Map<String, dynamic> data, {String? token}) => _post('/v1/sentinel/live-anemia-scan', data, token: token);

  // --- USERS ---
  Future<ApiResponse> listUsers({String? token}) => _get('/v1/user', token: token);
  Future<ApiResponse> createUser(Map<String, dynamic> data, {String? token}) => _post('/v1/user', data, token: token);
  Future<ApiResponse> getOwnProfile({String? token}) => _get('/v1/user/profile', token: token);
  Future<ApiResponse> updateOwnProfile(Map<String, dynamic> data, {String? token}) => _patch('/v1/user/profile', data, token: token);
  Future<ApiResponse> getUserById(String userId, {String? token}) => _get('/v1/user/$userId', token: token);
  Future<ApiResponse> updateUserById(String userId, Map<String, dynamic> data, {String? token}) => _patch('/v1/user/$userId', data, token: token);
  Future<ApiResponse> deleteUserById(String userId, {String? token}) => _delete('/v1/user/$userId', token: token);

  // --- GENERIC HTTP HELPERS ---
  Future<ApiResponse> _get(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client.get(uri, headers: _headers(token));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse> _post(String path, Map<String, dynamic> data, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client.post(uri, headers: _headers(token), body: jsonEncode(data));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse> _patch(String path, Map<String, dynamic> data, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client.patch(uri, headers: _headers(token), body: jsonEncode(data));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse> _delete(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client.delete(uri, headers: _headers(token));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  ApiResponse _parseResponse(http.Response response) {
    dynamic decodedBody;
    try {
      decodedBody = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      decodedBody = null;
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(response.statusCode, decodedBody, response.body);
    } else {
      final message = decodedBody is Map<String, dynamic> && decodedBody['message'] != null
          ? decodedBody['message'].toString()
          : 'API error: ${response.statusCode}';
      return ApiResponse.error(message, statusCode: response.statusCode, body: decodedBody, rawBody: response.body);
    }
  }
}

class ApiResponse {
  const ApiResponse._({this.statusCode, this.body, this.rawBody, this.errorMessage});

  factory ApiResponse.success(int statusCode, dynamic body, String rawBody) {
    return ApiResponse._(statusCode: statusCode, body: body, rawBody: rawBody);
  }

  factory ApiResponse.error(String message, {int? statusCode, dynamic body, String? rawBody}) {
    return ApiResponse._(statusCode: statusCode, body: body, rawBody: rawBody, errorMessage: message);
  }

  final int? statusCode;
  final dynamic body;
  final String? rawBody;
  final String? errorMessage;

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300 && errorMessage == null;
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
