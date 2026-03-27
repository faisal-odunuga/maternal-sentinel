import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

class MaternalSentinelApp extends StatelessWidget {
  const MaternalSentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maternal Sentinel',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          outline: AppColors.outline,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
