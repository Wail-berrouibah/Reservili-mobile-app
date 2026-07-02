import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/widgets/booking_calendar_widget.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
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
    final t = AppLocalizations.of(context);
    final calendarAsync = ref.watch(calendarProvider(_currentMonth));
    final reservationsAsync = ref.watch(reservationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.calendar)),
      body: Column(
        children: [
          _buildMonthHeader(),
          Expanded(
            child: calendarAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (data) {
                final checkOutDates = reservationsAsync.maybeWhen(
                  data: (reservations) {
                    final map = <String, Set<DateTime>>{};
                    for (final r in reservations.where((r) => r.isActive)) {
                      map.putIfAbsent(r.homeId, () => <DateTime>{})
                          .add(DateTime(r.checkOutDate.year, r.checkOutDate.month, r.checkOutDate.day));
                    }
                    return map;
                  },
                  orElse: () => <String, Set<DateTime>>{},
                );
                return BookingCalendarWidget(
                  homes: data.homes,
                  entries: data.entries,
                  month: _currentMonth,
                  checkOutDates: checkOutDates,
                  onReservationTap: (reservation) =>
                      context.push(AppRoutes.reservationDetails, extra: reservation.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    final monthName = months[_currentMonth.month - 1];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _prevMonth,
          ),
          Text(
            '$monthName ${_currentMonth.year}',
            style: AppTextStyles.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }
}
