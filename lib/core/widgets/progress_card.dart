import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'custom_card.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final IconData icon;

  const ProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.icon = Icons.track_changes_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.neonGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 12,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: AppColors.primaryDark,
            color: AppColors.neonGreen,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}
