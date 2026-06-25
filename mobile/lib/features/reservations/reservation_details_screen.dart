import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/utils/reservation_utils.dart';
import '../../shared/models/reservation_model.dart';
import '../../shared/widgets/soft_card.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';

class ReservationDetailsScreen extends StatelessWidget {
  final String reservationId;

  const ReservationDetailsScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context) {
    final resProvider = context.watch<ReservationsProvider>();
    final homesProvider = context.watch<HomesProvider>();
    final reservation = resProvider.getReservationById(reservationId);

    if (reservation == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Reservation not found')),
      );
    }

    final home = homesProvider.getHomeById(reservation.homeId);
    if (home != null) reservation..withHome(home);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Reservation Details'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildStatusHeader(reservation),
            const SizedBox(height: AppSpacing.xl),
            _buildGuestCard(reservation),
            const SizedBox(height: AppSpacing.xl),
            _buildDateCard(reservation),
            const SizedBox(height: AppSpacing.xl),
            if (home != null) _buildHomeCard(context, home, reservation),
            if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildNotesCard(reservation),
            ],
            if (reservation.status != ReservationStatus.cancelled) ...[
              const SizedBox(height: AppSpacing.xxl),
              _buildActions(context, reservation, resProvider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ReservationModel r) {
    return SoftCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _statusColor(r.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(_statusIcon(r.status), color: _statusColor(r.status), size: 28),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.status.label, style: AppTextStyles.title3.copyWith(color: _statusColor(r.status))),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Created ${du.DateUtils.formatDate(r.createdAt)}',
                  style: AppTextStyles.footnote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(ReservationModel r) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guest', style: AppTextStyles.title3),
          const SizedBox(height: AppSpacing.lg),
          _infoRow(Icons.person_outlined, r.guest.name),
          if (r.guest.phone != null) ...[
            const SizedBox(height: AppSpacing.md),
            _infoRow(Icons.phone_outlined, r.guest.phone!),
          ],
          if (r.guest.email != null) ...[
            const SizedBox(height: AppSpacing.md),
            _infoRow(Icons.email_outlined, r.guest.email!),
          ],
        ],
      ),
    );
  }

  Widget _buildDateCard(ReservationModel r) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stay Details', style: AppTextStyles.title3),
          const SizedBox(height: AppSpacing.lg),
          _dateRow('Check-in', r.checkIn),
          const SizedBox(height: AppSpacing.md),
          _dateRow('Check-out', r.checkOut),
          const Divider(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Duration', style: AppTextStyles.callout),
              Text('${r.nights} nights', style: AppTextStyles.headline),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price', style: AppTextStyles.callout),
              Text(
                '\$${r.totalPrice.toStringAsFixed(0)}',
                style: AppTextStyles.title2.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCard(BuildContext context, dynamic home, ReservationModel r) {
    return SoftCard(
      onTap: () => context.push('/homes/${home.id}'),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.home_outlined, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(home.name, style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.xxs),
                Text(home.address, style: AppTextStyles.footnote),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildNotesCard(ReservationModel r) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes', style: AppTextStyles.title3),
          const SizedBox(height: AppSpacing.md),
          Text(r.notes!, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ReservationModel r, ReservationsProvider provider) {
    return Column(
      children: [
        if (ReservationUtils.canReschedule(r.status))
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/reservations/${r.id}/reschedule'),
              icon: const Icon(Icons.date_range_outlined, size: 20),
              label: const Text('Reschedule'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),
        if (ReservationUtils.canCancel(r.status)) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _confirmCancel(context, r, provider),
              icon: const Icon(Icons.cancel_outlined, size: 20),
              label: const Text('Cancel Reservation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _confirmCancel(BuildContext context, ReservationModel r, ReservationsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Reservation'),
        content: Text('Are you sure you want to cancel ${r.guest.name}\'s reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              provider.cancelReservation(r.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Reservation cancelled'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(AppSpacing.lg),
                ),
              );
            },
            child: Text('Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Text(text, style: AppTextStyles.body),
      ],
    );
  }

  Widget _dateRow(String label, DateTime date) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.footnote),
            Text(du.DateUtils.formatDate(date), style: AppTextStyles.headline),
          ],
        ),
      ],
    );
  }

  Color _statusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed: return AppColors.confirmed;
      case ReservationStatus.rescheduled: return AppColors.rescheduled;
      case ReservationStatus.cancelled: return AppColors.cancelled;
    }
  }

  IconData _statusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed: return Icons.check_circle_outline;
      case ReservationStatus.rescheduled: return Icons.update_outlined;
      case ReservationStatus.cancelled: return Icons.cancel_outlined;
    }
  }
}
