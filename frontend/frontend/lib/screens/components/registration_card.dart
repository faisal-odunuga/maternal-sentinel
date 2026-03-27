import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

class RegistrationCard extends StatelessWidget {
  final ValueChanged<String> onSubmit;
  final bool isLoading;
  final TextEditingController bvnController;

  const RegistrationCard({
    super.key,
    required this.onSubmit,
    required this.bvnController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A191C1E),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Register as a Health Worker.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verify your credentials using your BVN to access the triage portal.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Bank Verification Number (BVN)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: bvnController,
              maxLength: 11,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !isLoading,
              decoration: InputDecoration(
                counterText: '',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.outline,
                  size: 20,
                ),
                hintText: 'Enter 11-digit number',
                hintStyle: const TextStyle(
                  color: AppColors.outline,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'We use this only for identity verification through secure channels.',
            style: TextStyle(fontSize: 10, color: AppColors.outline),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryContainer,
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
              ),
              onPressed: isLoading
                  ? null
                  : () => onSubmit(bvnController.text.trim()),
              iconAlignment: IconAlignment.end,
              icon: Icon(
                isLoading ? Icons.hourglass_bottom : Icons.arrow_forward,
                size: 18,
              ),
              label: Text(
                isLoading ? 'Verifying...' : 'Verify Identity',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user, size: 18, color: AppColors.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Secure AES-256 Encrypted Verification',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
