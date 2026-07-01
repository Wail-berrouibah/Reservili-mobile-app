import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/models/reservation_model.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/soft_card.dart';

class HomeDetailsScreen extends ConsumerWidget {
  final String homeId;
  const HomeDetailsScreen({super.key, required this.homeId});

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, AppLocalizations t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le logement ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.cancelled)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(homesProvider.notifier).deleteHome(homeId);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final homesAsync = ref.watch(homesProvider);
    final reservationsAsync = ref.watch(reservationsProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(t.homeDetails)),
      body: homesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (homes) {
          final match = homes.where((h) => h.id == homeId);
          if (match.isEmpty) {
            return Center(child: Text(t.homeNotFound));
          }
          final home = match.first;

          return reservationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (reservations) {
              final homeReservations = reservations
                  .where((r) => r.homeId == homeId && r.isActive)
                  .toList()
                ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: const Center(
                      child: Icon(Icons.home_work_outlined,
                          size: 64, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(home.name, style: AppTextStyles.headingLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(home.location, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SoftCard(
                    child: Column(
                      children: [
                        _row(t.capacity, t.persons(home.capacity)),
                        const Divider(height: AppSpacing.lg),
                        _row(
                          t.pricePerNightLabel,
                          t.pricePerNight(
                              home.pricePerNight.toStringAsFixed(0)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(t.reservedDays, style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _buildReservedDaysCalendar(now, homeReservations, t),
                  if (homeReservations.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    ...homeReservations.map((r) => _reservationTile(context, r, t)),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: t.book,
                    icon: Icons.event_available_outlined,
                    onPressed: () => context.push(
                      AppRoutes.createReservation,
                      extra: home.id,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Modifier',
                    variant: ButtonVariant.secondary,
                    icon: Icons.edit_outlined,
                    onPressed: () => context.push(
                      AppRoutes.addHome,
                      extra: home,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Supprimer',
                    variant: ButtonVariant.danger,
                    icon: Icons.delete_outline,
                    onPressed: () => _confirmDelete(context, ref, t),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReservedDaysCalendar(
    DateTime now,
    List<ReservationModel> reservations,
    AppLocalizations t,
  ) {
    final today = DateTime(now.year, now.month, now.day);

    if (reservations.isEmpty) {
      return SoftCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Aucune réservation pour ce logement.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    final startDate = today.subtract(const Duration(days: 15));
    final endDate = today.add(const Duration(days: 45));
    final dayCount = endDate.difference(startDate).inDays + 1;

    final occupiedDates = <DateTime>{};
    for (final r in reservations) {
      var d = DateTime(
        r.checkInDate.year,
        r.checkInDate.month,
        r.checkInDate.day,
      );
      while (d.isBefore(r.checkOutDate)) {
        if (!d.isBefore(startDate) && !d.isAfter(endDate)) {
          occupiedDates.add(d);
        }
        d = d.add(const Duration(days: 1));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${DateFormat('dd MMM').format(startDate)} → ${DateFormat('dd MMM').format(endDate)}',
          style: AppTextStyles.label,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dayCount,
            separatorBuilder: (_, __) => const SizedBox(width: 2),
            itemBuilder: (_, i) {
              final day = startDate.add(Duration(days: i));
              final isOccupied = occupiedDates.contains(day);
              final isPast = day.isBefore(today);

              return Container(
                width: 32,
                decoration: BoxDecoration(
                  color: isOccupied
                      ? (isPast
                          ? AppColors.confirmed.withOpacity(0.5)
                          : AppColors.confirmed)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: day == today ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: day == today
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isOccupied
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _reservationTile(BuildContext context, ReservationModel r, AppLocalizations t) {
    final statusLabel = switch (r.status) {
      ReservationStatus.confirmed => t.statusConfirmed,
      ReservationStatus.pending => t.statusPending,
      ReservationStatus.cancelled => t.statusCancelled,
    };
    final statusColor = switch (r.status) {
      ReservationStatus.confirmed => AppColors.confirmed,
      ReservationStatus.pending => AppColors.pending,
      ReservationStatus.cancelled => AppColors.cancelled,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push(AppRoutes.reservationDetails, extra: r.id),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppDateUtils.formatDay(r.checkInDate)} → ${AppDateUtils.formatDay(r.checkOutDate)}',
                      style: AppTextStyles.bodyLarge,
                    ),
                    Text(
                      '${r.guestsCount} personnes',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}
