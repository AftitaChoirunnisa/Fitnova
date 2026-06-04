import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/pages/splash_screen.dart';

class FitNovaApp extends StatelessWidget {
  const FitNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitNova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
