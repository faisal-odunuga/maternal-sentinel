import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Interswitch',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  color: Color(0x88000000),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                height: 16,
                child: VerticalDivider(
                  color: AppColors.outlineVariant,
                  thickness: 1,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'ENYATA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0x88000000),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '© 2024 Maternal Sentinel. In partnership with Interswitch & Enyata.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0x99000000),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x99000000),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 18),
              Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x99000000),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
