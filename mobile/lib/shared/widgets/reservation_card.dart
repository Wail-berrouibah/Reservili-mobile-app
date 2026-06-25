import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart' as du;
import '../models/reservation_model.dart';
import 'soft_card.dart';
import 'status_badge.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback? onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Center(
                  child: Icon(Icons.person_outline, color: AppColors.primary, size: 22),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.guest.name,
                      style: AppTextStyles.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      reservation.home.name,
                      style: AppTextStyles.footnote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: reservation.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildInfoColumn(
                icon: Icons.calendar_today_outlined,
                label: 'Check-in',
                value: du.DateUtils.formatDate(reservation.checkIn),
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildInfoColumn(
                icon: Icons.calendar_today_outlined,
                label: 'Check-out',
                value: du.DateUtils.formatDate(reservation.checkOut),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${reservation.nights} nights', style: AppTextStyles.footnote),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '\$${reservation.totalPrice.toStringAsFixed(0)}',
                    style: AppTextStyles.headline.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xxs),
            Text(label, style: AppTextStyles.caption2),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: AppTextStyles.callout),
      ],
    );
  }
}
