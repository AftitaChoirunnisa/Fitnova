import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.softMint,
      side: const BorderSide(color: AppColors.borderSoft, width: 1.5),
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

    final Widget child = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.softMint,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.softMint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );
  }
}
