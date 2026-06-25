import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/soft_card.dart';
import '../../providers/reservations_provider.dart';

class RescheduleReservationScreen extends StatefulWidget {
  final String reservationId;

  const RescheduleReservationScreen({super.key, required this.reservationId});

  @override
  State<RescheduleReservationScreen> createState() => _RescheduleReservationScreenState();
}

class _RescheduleReservationScreenState extends State<RescheduleReservationScreen> {
  DateTime? _newCheckIn;
  DateTime? _newCheckOut;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _newCheckIn != null && _newCheckOut != null
          ? DateTimeRange(start: _newCheckIn!, end: _newCheckOut!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) {
      setState(() {
        _newCheckIn = result.start;
        _newCheckOut = result.end;
      });
    }
  }

  void _submit() {
    final provider = context.read<ReservationsProvider>();
    final reservation = provider.getReservationById(widget.reservationId);

    if (reservation == null) return;
    if (_newCheckIn == null || _newCheckOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select new dates'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
      return;
    }

    if (provider.hasOverlap(reservation.homeId, _newCheckIn!, _newCheckOut!, widget.reservationId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Those dates overlap with another reservation'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
      return;
    }

    provider.rescheduleReservation(widget.reservationId, _newCheckIn!, _newCheckOut!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reservation rescheduled successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final reservation = context.watch<ReservationsProvider>().getReservationById(widget.reservationId);

    if (reservation == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Reservation not found')),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Reschedule')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Dates', style: AppTextStyles.title3),
              const SizedBox(height: AppSpacing.md),
              SoftCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(Icons.calendar_month_outlined, color: AppColors.warning, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            du.DateUtils.formatDateRange(reservation.checkIn, reservation.checkOut),
                            style: AppTextStyles.headline,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${reservation.nights} nights',
                            style: AppTextStyles.footnote,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Select New Dates', style: AppTextStyles.title3),
              const SizedBox(height: AppSpacing.md),
              SoftCard(
                onTap: _pickDateRange,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(Icons.date_range_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _newCheckIn != null && _newCheckOut != null
                                ? du.DateUtils.formatDateRange(_newCheckIn!, _newCheckOut!)
                                : 'Tap to select new dates',
                            style: AppTextStyles.headline.copyWith(
                              color: _newCheckIn != null ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                          if (_newCheckIn != null && _newCheckOut != null)
                            Text(
                              '${du.DateUtils.nightsBetween(_newCheckIn!, _newCheckOut!)} nights',
                              style: AppTextStyles.footnote,
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                  ],
                ),
              ),
              if (_newCheckIn != null && _newCheckOut != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'The status will be updated to "Rescheduled"',
                          style: AppTextStyles.footnote.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl * 2),
              PrimaryButton(
                label: 'Confirm Reschedule',
                icon: Icons.check_circle_outline,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
