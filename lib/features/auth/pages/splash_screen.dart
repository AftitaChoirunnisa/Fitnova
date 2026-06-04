import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.softCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSoft, width: 1.5),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primaryGreen,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'FITNOVA',
              style: AppTextStyles.headingLarge.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Move Better. Live Stronger.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
