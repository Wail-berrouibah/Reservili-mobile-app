import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ReservationDatePicker extends StatefulWidget {
  final Set<DateTime> reservedDates;
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final ValueChanged<DateTime>? onDayTap;
  final bool selectable;
  final bool showLegend;
  final bool reservedAsOccupied;
  final DateTime? initialMonth;

  const ReservationDatePicker({
    super.key,
    required this.reservedDates,
    this.selectedStart,
    this.selectedEnd,
    this.onDayTap,
    this.selectable = true,
    this.showLegend = true,
    this.reservedAsOccupied = true,
    this.initialMonth,
  });

  @override
  State<ReservationDatePicker> createState() => _ReservationDatePickerState();
}

class _ReservationDatePickerState extends State<ReservationDatePicker> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = widget.initialMonth ?? DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMonthHeader(),
        const SizedBox(height: AppSpacing.sm),
        _buildWeekdayHeaders(),
        const SizedBox(height: AppSpacing.xs),
        _buildDayGrid(),
        if (widget.showLegend) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildLegend(),
        ],
      ],
    );
  }

  Widget _buildMonthHeader() {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    final monthName = months[_currentMonth.month - 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: _prevMonth,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          '$monthName ${_currentMonth.year}',
          style: AppTextStyles.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: _nextMonth,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const headers = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return Row(
      children: headers.map((d) {
        return Expanded(
          child: Center(
            child: Text(d, style: AppTextStyles.label),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final cells = <Widget>[];

    for (var i = 1; i < firstWeekday; i++) {
      cells.add(const Expanded(child: SizedBox(height: 32)));
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      cells.add(_buildDayCell(date, today));
    }

    return Wrap(
      children: cells.map((c) => SizedBox(width: (MediaQuery.of(context).size.width - 32) / 7, child: c)).toList(),
    );
  }

  Widget _buildDayCell(DateTime date, DateTime today) {
    final isReserved = widget.reservedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
    final isPast = date.isBefore(today);
    final isToday = date == today;
    final isStart = widget.selectedStart != null &&
        widget.selectedStart!.year == date.year &&
        widget.selectedStart!.month == date.month &&
        widget.selectedStart!.day == date.day;
    final isEnd = widget.selectedEnd != null &&
        widget.selectedEnd!.year == date.year &&
        widget.selectedEnd!.month == date.month &&
        widget.selectedEnd!.day == date.day;
    final inRange = widget.selectedStart != null &&
        widget.selectedEnd != null &&
        date.isAfter(widget.selectedStart!) &&
        date.isBefore(widget.selectedEnd!);

    Color bgColor;
    Color textColor;

    if (isReserved && widget.reservedAsOccupied) {
      bgColor = AppColors.cancelled.withValues(alpha: 0.85);
      textColor = AppColors.textOnPrimary;
    } else if (isStart || isEnd) {
      bgColor = AppColors.primary;
      textColor = AppColors.textOnPrimary;
    } else if (inRange) {
      bgColor = AppColors.primary.withValues(alpha: 0.25);
      textColor = AppColors.textPrimary;
    } else if (isReserved && !widget.reservedAsOccupied) {
      bgColor = AppColors.confirmed;
      textColor = AppColors.textOnPrimary;
    } else if (isToday) {
      bgColor = AppColors.accentLight;
      textColor = AppColors.textPrimary;
    } else {
      bgColor = AppColors.card;
      textColor = AppColors.textPrimary;
    }

    return GestureDetector(
      onTap: (!isPast && widget.selectable && !isReserved)
          ? () => widget.onDayTap?.call(date)
          : null,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isToday ? AppColors.accent : AppColors.border,
            width: isToday ? 1.5 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(AppColors.cancelled, 'Occupé'),
        const SizedBox(width: AppSpacing.sm),
        _legendItem(AppColors.card, 'Libre'),
        if (widget.selectable) ...[
          const SizedBox(width: AppSpacing.sm),
          _legendItem(AppColors.primary, 'Sélectionné'),
        ],
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
}
