import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum ButtonVariant { primary, secondary, danger }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final ButtonVariant variant;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    final bg = switch (variant) {
      ButtonVariant.primary => AppColors.primary,
      ButtonVariant.secondary => AppColors.surface,
      ButtonVariant.danger => AppColors.cancelled,
    };
    final fg = switch (variant) {
      ButtonVariant.primary => Colors.white,
      ButtonVariant.secondary => AppColors.primary,
      ButtonVariant.danger => Colors.white,
    };
    final side = variant == ButtonVariant.secondary
        ? const BorderSide(color: AppColors.primary, width: 1.4)
        : BorderSide.none;

    return SizedBox(
      height: AppSpacing.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          disabledBackgroundColor: bg.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: side,
          ),
        ),
        child: loading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
