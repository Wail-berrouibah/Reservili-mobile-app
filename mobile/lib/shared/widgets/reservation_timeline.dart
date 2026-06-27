import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ReservationTimeline extends StatelessWidget {
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const ReservationTimeline({
    super.key,
    required this.checkInDate,
    required this.checkOutDate,
  });

  int get _nights {
    final inMidnight = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    final outMidnight = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    return outMidnight.difference(inMidnight).inDays;
  }

  @override
  Widget build(BuildContext context) {
    var nights = _nights;
    if (nights <= 0) nights = 1;

    final segments = List.generate(nights, (i) {
      return DateTime(
        checkInDate.year,
        checkInDate.month,
        checkInDate.day + i,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: SizedBox(
            height: 44,
            child: Row(
              children: segments.asMap().entries.map((entry) {
                final idx = entry.key;
                return Expanded(child: _buildSegment(idx, nights));
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: segments.map((date) {
            return Expanded(
              child: Text(
                DateFormat('dd MMM').format(date),
                textAlign: TextAlign.center,
                style: AppTextStyles.label,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSegment(int index, int total) {
    if (total == 1) {
      return Stack(
        children: [
          Container(color: AppColors.border),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerEnd,
            widthFactor: 0.5,
            child: Container(color: AppColors.confirmed),
          ),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 0.33,
            child: Container(color: AppColors.cancelled),
          ),
        ],
      );
    }

    if (index == 0) {
      return Stack(
        children: [
          Container(color: AppColors.border),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerEnd,
            widthFactor: 0.5,
            child: Container(color: AppColors.confirmed),
          ),
        ],
      );
    }

    if (index == total - 1) {
      return Stack(
        children: [
          Container(color: AppColors.border),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 0.33,
            child: Container(color: AppColors.cancelled),
          ),
        ],
      );
    }

    return Container(color: AppColors.confirmed);
  }
}
