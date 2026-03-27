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
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        IdentityOnboardingScreen.routeName: (context) => const IdentityOnboardingScreen(),
        VerifyBvnScreen.routeName: (context) => const VerifyBvnScreen(),
        MidwifeCommandCenterScreen.routeName: (context) => const MidwifeCommandCenterScreen(),
        AddVisitScreen.routeName: (context) => const AddVisitScreen(patientId: 0), // patientId should be passed via arguments
        SentinelAIScanScreen.routeName: (context) => const SentinelAIScanScreen(),
        EmergencyReferralScreen.routeName: (context) => const EmergencyReferralScreen(),
      },
      onGenerateRoute: (settings) {
        // Example for AddVisitScreen with arguments
        if (settings.name == AddVisitScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>?;
          final patientId = args != null && args['patientId'] != null ? args['patientId'] as int : 0;
          return MaterialPageRoute(
            builder: (context) => AddVisitScreen(patientId: patientId),
          );
        }
        return null;
      },
    );
  }
}
