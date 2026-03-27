import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14001E40),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Icon(
                Icons.shield_outlined,
                color: AppColors.secondaryFixed,
                size: 34,
              ),
              Positioned(
                bottom: 18,
                child: Icon(Icons.monitor_heart, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Maternal Sentinel',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
