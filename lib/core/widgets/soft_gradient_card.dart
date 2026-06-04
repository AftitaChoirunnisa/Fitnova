import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SoftGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;

  const SoftGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.begin,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: const [AppColors.darkGreen, AppColors.mediumGreen],
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.borderSoft, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
