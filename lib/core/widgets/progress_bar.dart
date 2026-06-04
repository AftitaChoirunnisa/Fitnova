import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final double value; // Between 0.0 and 1.0
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.darkGreen,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: progressColor ?? AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
