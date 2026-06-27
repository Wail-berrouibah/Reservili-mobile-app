import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/reservation_model.dart';
import 'soft_card.dart';
import 'status_badge.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final String homeName;
  final String guestName;
  final VoidCallback? onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.homeName,
    required this.guestName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM');
    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(homeName, style: AppTextStyles.titleMedium),
              ),
              StatusBadge(status: reservation.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(guestName, style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${df.format(reservation.checkInDate)} → ${df.format(reservation.checkOutDate)} · ${reservation.nights} nuits',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
