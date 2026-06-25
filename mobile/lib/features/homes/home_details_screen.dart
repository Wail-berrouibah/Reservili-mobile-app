import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/utils/reservation_utils.dart';
import '../../shared/models/home_model.dart';
import '../../shared/models/reservation_model.dart';
import '../../shared/widgets/reservation_card.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';

class HomeDetailsScreen extends StatelessWidget {
  final String homeId;

  const HomeDetailsScreen({super.key, required this.homeId});

  @override
  Widget build(BuildContext context) {
    final homesProvider = context.watch<HomesProvider>();
    final reservationsProvider = context.watch<ReservationsProvider>();
    final home = homesProvider.getHomeById(homeId);

    if (home == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Home not found')),
      );
    }

    final reservations = reservationsProvider
        .getReservationsForHome(homeId)
        .map((r) => r.withHome(home))
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(home.name),
          actions: [
            IconButton(
              onPressed: () {
                _showAvailabilityDialog(context, home, reservationsProvider);
              },
              icon: const Icon(Icons.event_available_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildImageSection(home),
            const SizedBox(height: AppSpacing.xl),
            _buildTitleSection(home),
            const SizedBox(height: AppSpacing.lg),
            _buildInfoRow(home),
            const SizedBox(height: AppSpacing.xxl),
            _buildDescription(home),
            const SizedBox(height: AppSpacing.xxl),
            _buildBookButton(context, home, reservationsProvider),
            const SizedBox(height: AppSpacing.xxl),
            _buildReservationsSection(context, reservations),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(HomeModel home) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        height: 220,
        color: AppColors.background,
        child: home.imageUrl != null
            ? Image.asset(home.imageUrl!, fit: BoxFit.cover, width: double.infinity)
            : Center(
                child: Icon(Icons.home_outlined, size: 64, color: AppColors.textTertiary),
              ),
      ),
    );
  }

  Widget _buildTitleSection(HomeModel home) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(home.name, style: AppTextStyles.title1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(home.address, style: AppTextStyles.callout),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: home.isAvailable
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            home.isAvailable ? 'Available' : 'Unavailable',
            style: AppTextStyles.footnote.copyWith(
              color: home.isAvailable ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(HomeModel home) {
    return Row(
      children: [
        _infoChip(Icons.attach_money_outlined, '\$${home.pricePerNight.toStringAsFixed(0)} / night'),
        const SizedBox(width: AppSpacing.md),
        _infoChip(Icons.people_outline, 'Up to ${home.maxGuests} guests'),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.footnote),
        ],
      ),
    );
  }

  Widget _buildDescription(HomeModel home) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppTextStyles.title3),
        const SizedBox(height: AppSpacing.sm),
        Text(home.description, style: AppTextStyles.body),
      ],
    );
  }

  Widget _buildBookButton(BuildContext context, HomeModel home, ReservationsProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => context.push('/reservations/create', extra: home),
        icon: const Icon(Icons.calendar_today_outlined, size: 20),
        label: const Text('Book This Home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }

  Widget _buildReservationsSection(BuildContext c, List<ReservationModel> reservations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reservations', style: AppTextStyles.title3),
        const SizedBox(height: AppSpacing.md),
        if (reservations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy_outlined, size: 36, color: AppColors.textTertiary),
                const SizedBox(height: AppSpacing.md),
                Text('No reservations yet', style: AppTextStyles.callout),
              ],
            ),
          )
        else
          ...reservations.map((r) => ReservationCard(
            reservation: r,
            onTap: () => c.push('/reservations/${r.id}'),
          )),
      ],
    );
  }

  void _showAvailabilityDialog(
    BuildContext context,
    HomeModel home,
    ReservationsProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final reservations = provider.getReservationsForHome(home.id);
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Availability for ${home.name}', style: AppTextStyles.title3),
              const SizedBox(height: AppSpacing.lg),
              if (reservations.isEmpty)
                Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Text('Fully available — no reservations yet', style: AppTextStyles.body),
                  ],
                )
              else
                ...reservations.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: r.status == ReservationStatus.cancelled
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          r.status == ReservationStatus.cancelled
                              ? Icons.block
                              : Icons.event_busy,
                          size: 18,
                          color: r.status == ReservationStatus.cancelled
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r.guest.name} — ${r.status.label}',
                              style: AppTextStyles.headline.copyWith(fontSize: 15),
                            ),
                            Text(
                              du.DateUtils.formatDateRange(r.checkIn, r.checkOut),
                              style: AppTextStyles.footnote,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
