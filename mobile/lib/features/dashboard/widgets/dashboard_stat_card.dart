import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/soft_card.dart';

class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTextStyles.headingLarge),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
