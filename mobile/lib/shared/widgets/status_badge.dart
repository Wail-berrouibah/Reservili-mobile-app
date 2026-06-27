import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../models/reservation_model.dart';

class StatusBadge extends StatelessWidget {
  final ReservationStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: config.color.withOpacity(0.4)),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  _BadgeConfig _config(ReservationStatus s) {
    switch (s) {
      case ReservationStatus.confirmed:
        return const _BadgeConfig('Confirmée', AppColors.confirmed);
      case ReservationStatus.cancelled:
        return const _BadgeConfig('Annulée', AppColors.cancelled);
      case ReservationStatus.pending:
        return const _BadgeConfig('En attente', AppColors.pending);
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color color;
  const _BadgeConfig(this.label, this.color);
}
