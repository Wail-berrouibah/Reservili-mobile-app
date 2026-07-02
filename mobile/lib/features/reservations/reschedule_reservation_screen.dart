import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/widgets/primary_button.dart';

class RescheduleReservationScreen extends ConsumerStatefulWidget {
  final String reservationId;
  const RescheduleReservationScreen(
      {super.key, required this.reservationId});

  @override
  ConsumerState<RescheduleReservationScreen> createState() =>
      _RescheduleReservationScreenState();
}

class _RescheduleReservationScreenState
    extends ConsumerState<RescheduleReservationScreen> {
  DateTimeRange? _range;
  TimeOfDay _checkInTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reservations = ref.read(reservationsProvider).asData?.value ?? [];
      final match = reservations.where((r) => r.id == widget.reservationId);
      if (match.isNotEmpty) {
        final r = match.first;
        setState(() {
          _checkInTime = TimeOfDay.fromDateTime(r.checkInDate);
          _checkOutTime = TimeOfDay.fromDateTime(r.checkOutDate);
        });
      }
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _pickCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime,
    );
    if (picked != null) setState(() => _checkInTime = picked);
  }

  Future<void> _pickCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime,
    );
    if (picked != null) setState(() => _checkOutTime = picked);
  }

  DateTime _combine(DateTime date, TimeOfDay time) => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

  Future<void> _submit(AppLocalizations t) async {
    if (_range == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(reservationsProvider.notifier).reschedule(
            widget.reservationId,
            _combine(_range!.start, _checkInTime),
            _combine(_range!.end, _checkOutTime),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.reservationRescheduled)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('GAP_NOT_ALLOWED')
            ? t.gapWarning
            : t.datesUnavailable;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.reschedule)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ListView(
          children: [
            Text(t.newDates, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickRange,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _range == null
                            ? t.chooseDates
                            : AppDateUtils.rangeLabel(
                                _range!.start, _range!.end),
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _RescheduleTimeTile(
                    label: t.arrival,
                    time: _checkInTime,
                    onTap: _pickCheckInTime,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _RescheduleTimeTile(
                    label: t.departure,
                    time: _checkOutTime,
                    onTap: _pickCheckOutTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: t.reschedule,
              loading: _saving,
              onPressed: _range == null ? null : () => _submit(t),
            ),
          ],
        ),
      ),
    );
  }
}

class _RescheduleTimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _RescheduleTimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = time.format(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Text(display, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}
