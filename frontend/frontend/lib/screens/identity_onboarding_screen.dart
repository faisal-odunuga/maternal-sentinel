import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'midwife_command_center_screen.dart';
import 'components/brand_header.dart';
import 'components/registration_card.dart';
import 'components/app_footer.dart';

class IdentityOnboardingScreen extends StatefulWidget {
  const IdentityOnboardingScreen({super.key});

  @override
  State<IdentityOnboardingScreen> createState() =>
      _IdentityOnboardingScreenState();
}

class _IdentityOnboardingScreenState extends State<IdentityOnboardingScreen> {
  bool _isLoading = false;
  final TextEditingController _bvnController = TextEditingController();

  @override
  void dispose() {
    _bvnController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify(String bvn) async {
    if (bvn.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 11-digit BVN.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _LoadingModal(),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.of(context).pop();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _VerifiedModal(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MidwifeCommandCenterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offset =
              Tween<Offset>(
                begin: const Offset(0.12, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return SlideTransition(
            position: offset,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      keyboardOpen ? 16 : 24,
                      16,
                      keyboardOpen ? 16 : 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const BrandHeader(),
                              const SizedBox(height: 26),
                              RegistrationCard(
                                isLoading: _isLoading,
                                bvnController: _bvnController,
                                onSubmit: _handleVerify,
                              ),
                              const SizedBox(height: 24),
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                    height: 1.45,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Need help with your registration? ',
                                    ),
                                    TextSpan(
                                      text: 'Contact Support',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!keyboardOpen) const AppFooter(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadingModal extends StatelessWidget {
  const _LoadingModal();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verifying Identity',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait while we verify your credentials...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedModal extends StatefulWidget {
  const _VerifiedModal();

  @override
  State<_VerifiedModal> createState() => _VerifiedModalState();
}

class _VerifiedModalState extends State<_VerifiedModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CheckPainter(progress: _controller.value),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Identity Verified',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your credentials have been verified successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;

  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p1 = Offset(size.width * 0.27, size.height * 0.54);
    final p2 = Offset(size.width * 0.45, size.height * 0.70);
    final p3 = Offset(size.width * 0.76, size.height * 0.34);

    final firstSegment = (progress * 2).clamp(0.0, 1.0);
    final secondSegment = ((progress - 0.5) * 2).clamp(0.0, 1.0);

    if (firstSegment > 0) {
      final to = Offset.lerp(p1, p2, firstSegment)!;
      canvas.drawLine(p1, to, paint);
    }

    if (secondSegment > 0) {
      final to = Offset.lerp(p2, p3, secondSegment)!;
      canvas.drawLine(p2, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
