import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';


class AuthRepository {
  AuthRepository({required ApiService apiService, FlutterSecureStorage? storage})
      : _apiService = apiService,
        _storage = storage ?? const FlutterSecureStorage();

  static const String tokenStorageKey = 'auth_token';
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  Future<VerifyBvnResult> verifyBvn(String bvn) async {
    try {
      final response = await _apiService.verifyBvn(bvn);

      switch (response.statusCode) {
        case 200:
          if (response.body is! Map<String, dynamic>) {
            return VerifyBvnResult.failure(
              message: 'Invalid response from server.',
            );
          }

          final data = response.body as Map<String, dynamic>;
          final token = data['token']?.toString();
          final userId = data['user_id']?.toString();
          final clinicId = data['clinic_id']?.toString();
          final role = data['role']?.toString();

          if ([token, userId, clinicId, role].any((value) => value == null)) {
            return VerifyBvnResult.failure(
              message: 'Incomplete auth response from server.',
            );
          }

          await _storage.write(key: tokenStorageKey, value: token);

          return VerifyBvnResult.success(
            session: AuthSession(
              token: token!,
              userId: userId!,
              clinicId: clinicId!,
              role: role!,
            ),
          );

        case 401:
          return VerifyBvnResult.failure(message: 'BVN not verified');
        case 400:
          return VerifyBvnResult.failure(
            message: _extractValidationMessage(response.body),
          );
        case 503:
          return VerifyBvnResult.failure(
            message: 'Auth service unavailable, try again',
          );
        default:
          return VerifyBvnResult.failure(
            message: 'Something went wrong. Please try again.',
          );
      }
    } catch (_) {
      return VerifyBvnResult.failure(
        message: 'Unable to connect. Check your network and API base URL.',
      );
    }
  }

  String _extractValidationMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['error'] ?? body['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return 'Invalid BVN input.';
  }
}

class VerifyBvnResult {
  const VerifyBvnResult._({this.session, this.message});

  factory VerifyBvnResult.success({required AuthSession session}) {
    return VerifyBvnResult._(session: session);
  }

  factory VerifyBvnResult.failure({required String message}) {
    return VerifyBvnResult._(message: message);
  }

  final AuthSession? session;
  final String? message;

  bool get isSuccess => session != null;
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.clinicId,
    required this.role,
  });

  final String token;
  final String userId;
  final String clinicId;
  final String role;
}
