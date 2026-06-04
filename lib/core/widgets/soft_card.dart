import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;
  final VoidCallback? onTap;

  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.softCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
