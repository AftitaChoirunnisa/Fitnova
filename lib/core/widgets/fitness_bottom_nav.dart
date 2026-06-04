// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FitnessBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const FitnessBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.fitness_center_rounded, 'label': 'Activities'},
      {'icon': Icons.emoji_events_rounded, 'label': 'Challenge'},
      {'icon': Icons.leaderboard_rounded, 'label': 'Leaderboard'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = selectedIndex == index;
            final item = items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
