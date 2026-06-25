import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/reservation_utils.dart';

class StatusBadge extends StatelessWidget {
  final ReservationStatus status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  Color get _color {
    switch (status) {
      case ReservationStatus.confirmed:
        return AppColors.confirmed;
      case ReservationStatus.rescheduled:
        return AppColors.rescheduled;
      case ReservationStatus.cancelled:
        return AppColors.cancelled;
    }
  }

  Color get _bgColor {
    return _color.withValues(alpha: 0.12);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
