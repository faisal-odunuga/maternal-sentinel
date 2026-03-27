import 'package:flutter/material.dart';

import '../controllers/verify_bvn_controller.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'midwife_command_center_screen.dart';

class VerifyBvnScreen extends StatefulWidget {
  const VerifyBvnScreen({super.key});

  @override
  State<VerifyBvnScreen> createState() => _VerifyBvnScreenState();
}

class _VerifyBvnScreenState extends State<VerifyBvnScreen> {
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  late final VerifyBvnController _controller;
  final TextEditingController _bvnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = VerifyBvnController(
      authRepository: AuthRepository(
        apiService: AuthApiService(baseUrl: _defaultBaseUrl),
      ),
    );
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _bvnController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    final errorMessage = _controller.errorMessage;
    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final isSuccess = await _controller.verify(_bvnController.text);
    if (!mounted || !isSuccess) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MidwifeCommandCenterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('BVN Login'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Enter your 11-digit BVN to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _bvnController,
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        enabled: !_controller.isLoading,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'BVN',
                          hintText: 'Enter BVN',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'API Base URL: $_defaultBaseUrl\nUse --dart-define=API_BASE_URL=http://<local-ip>:5000 for physical device.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _controller.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: _controller.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Verify BVN'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
