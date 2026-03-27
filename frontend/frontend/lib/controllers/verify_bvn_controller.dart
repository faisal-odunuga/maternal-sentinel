import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';

class VerifyBvnController extends ChangeNotifier {
  VerifyBvnController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  AuthSession? _session;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthSession? get session => _session;

  Future<bool> verify(String bvn) async {
    final normalizedBvn = bvn.trim();

    if (!_isValidBvn(normalizedBvn)) {
      _errorMessage = 'Please enter a valid 11-digit BVN.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.verifyBvn(normalizedBvn);

    _isLoading = false;
    if (result.isSuccess) {
      _session = result.session;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _errorMessage = result.message;
    notifyListeners();
    return false;
  }

  bool _isValidBvn(String bvn) {
    final bvnRegex = RegExp(r'^\d{11}$');
    return bvnRegex.hasMatch(bvn);
  }
}
