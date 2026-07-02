import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/models/home_model.dart';
import '../../shared/models/reservation_model.dart';

class BookingCalendarWidget extends StatelessWidget {
  final List<HomeModel> homes;
  final Map<String, Map<DateTime, ReservationModel?>> entries;
  final DateTime month;
  final Map<String, Set<DateTime>> checkOutDates;
  final void Function(ReservationModel reservation)? onReservationTap;
  final int Function(String homeId, DateTime date)? voidCountBuilder;

  const BookingCalendarWidget({
    super.key,
    required this.homes,
    required this.entries,
    required this.month,
    this.checkOutDates = const {},
    this.onReservationTap,
    this.voidCountBuilder,
  });

  int get _daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth;
    const cellSize = 36.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegend(),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(days, cellSize),
                ...homes.map((home) => _buildHomeRow(home, days, cellSize)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(AppColors.confirmed, 'Confirmé'),
        const SizedBox(width: AppSpacing.sm),
        _legendItem(AppColors.pending, 'En attente'),
        const SizedBox(width: AppSpacing.sm),
        _legendItem(AppColors.card, 'Libre'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: color == AppColors.card
                ? Border.all(color: AppColors.border)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }

  Widget _buildHeaderRow(int days, double cellSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 90,
          height: 20,
          child: Text('', style: AppTextStyles.label),
        ),
        ...List.generate(days, (i) {
          final day = DateTime(month.year, month.month, i + 1);
          final weekday = DateFormat('E').format(day).substring(0, 2);
          return SizedBox(
            width: cellSize,
            child: Column(
              children: [
                Text(weekday, style: AppTextStyles.label),
                Text('${i + 1}', style: AppTextStyles.label),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHomeRow(HomeModel home, int days, double cellSize) {
    final homeMap = entries[home.id];
    if (homeMap == null) return const SizedBox.shrink();

    final homeCheckOuts = checkOutDates[home.id] ?? const <DateTime>{};

    return Row(
      children: [
        SizedBox(
          width: 90,
          height: cellSize,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              home.name,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        ...List.generate(days, (i) {
          final day = DateTime(month.year, month.month, i + 1);
          final reservation = homeMap[day];
          return _buildCell(reservation, cellSize, day, homeCheckOuts);
        }),
      ],
    );
  }

  bool _matchesDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildCell(ReservationModel? reservation, double cellSize, DateTime day, Set<DateTime> homeCheckOuts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCheckOut = homeCheckOuts.any((d) => _matchesDate(d, day));
    final isToday = _matchesDate(day, today);

    if (isCheckOut) {
      return GestureDetector(
        onTap: onReservationTap != null ? () => onReservationTap!(reservation!) : null,
        child: Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            border: Border.all(
              color: isToday ? AppColors.accent : AppColors.border,
              width: isToday ? 1.5 : 0.5,
            ),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(color: AppColors.card),
                  ),
                  Expanded(
                    child: Container(
                      color: AppColors.cancelled.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              if (isToday)
                Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Color bgColor;
    Color? borderColor;

    if (reservation != null) {
      switch (reservation.status) {
        case ReservationStatus.confirmed:
          bgColor = AppColors.confirmed;
        case ReservationStatus.pending:
          bgColor = AppColors.pending;
        case ReservationStatus.cancelled:
          bgColor = AppColors.border;
      }
    } else {
      bgColor = AppColors.card;
      borderColor = AppColors.border;
    }

    return GestureDetector(
      onTap: reservation != null && onReservationTap != null
          ? () => onReservationTap!(reservation)
          : null,
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isToday ? AppColors.accent : (borderColor ?? Colors.transparent),
            width: isToday ? 1.5 : 0.5,
          ),
        ),
        child: isToday
            ? Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
