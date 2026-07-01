import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/models/home_model.dart';
import '../../shared/models/reservation_model.dart';
import '../../shared/widgets/empty_state.dart';

class SearchAvailabilityScreen extends ConsumerStatefulWidget {
  const SearchAvailabilityScreen({super.key});

  @override
  ConsumerState<SearchAvailabilityScreen> createState() =>
      _SearchAvailabilityScreenState();
}

class _SearchAvailabilityScreenState
    extends ConsumerState<SearchAvailabilityScreen> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _selectedDate ?? now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.availability)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _pickDate,
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
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? t.chooseDate
                            : AppDateUtils.formatShort(_selectedDate!),
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _selectedDate == null
                  ? EmptyState(
                      icon: Icons.calendar_today_outlined,
                      title: t.chooseDate,
                      message: '',
                    )
                  : _buildAvailabilityList(_selectedDate!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityList(DateTime date) {
    return Consumer(
      builder: (context, ref, _) {
        final homesAsync = ref.watch(homesProvider);
        final reservationsAsync = ref.watch(reservationsProvider);

        return homesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (homes) {
            return reservationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (reservations) {
                final t = AppLocalizations.of(context);
                final available = <HomeModel>[];
                final occupied = <MapEntry<HomeModel, ReservationModel>>[];

                for (final home in homes) {
                  if (home.status != HomeStatus.available) continue;
                  final covering = reservations.cast<ReservationModel?>().firstWhere(
                    (r) =>
                        r != null &&
                        r.isActive &&
                        r.homeId == home.id &&
                        !r.checkInDate.isAfter(date) &&
                        date.isBefore(r.checkOutDate),
                    orElse: () => null,
                  );
                  if (covering != null) {
                    occupied.add(MapEntry(home, covering));
                  } else {
                    available.add(home);
                  }
                }

                return ListView(
                  children: [
                    if (available.isNotEmpty) ...[
                      Text(t.availableRooms(available.length),
                          style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      ...available.map(
                        (home) => _homeTile(
                          home: home,
                          available: true,
                          onTap: () => context.push(
                            AppRoutes.createReservation,
                            extra: home.id,
                          ),
                        ),
                      ),
                    ],
                    if (occupied.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(t.occupiedRooms(occupied.length),
                          style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      ...occupied.map(
                        (e) => _homeTile(home: e.key, reservation: e.value),
                      ),
                    ],
                    if (available.isEmpty && occupied.isEmpty)
                      EmptyState(
                        icon: Icons.search_off_outlined,
                        title: t.noHomesAvailable,
                        message: t.tryOtherDates,
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _homeTile({
    required HomeModel home,
    bool available = false,
    ReservationModel? reservation,
    VoidCallback? onTap,
  }) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: available ? AppColors.confirmed : AppColors.border,
        ),
      ),
      child: ListTile(
        leading: Icon(
          available ? Icons.check_circle_outline : Icons.block,
          color: available ? AppColors.confirmed : AppColors.cancelled,
        ),
        title: Text(home.name, style: AppTextStyles.bodyLarge),
        subtitle: Text(
          available
              ? 'Libre • ${home.pricePerNight.toStringAsFixed(0)} DA/nuit'
              : 'Occupé • ${reservation!.status == ReservationStatus.confirmed ? "Confirmé" : "En attente"}',
          style: AppTextStyles.bodyMedium,
        ),
        trailing: available
            ? const Icon(Icons.chevron_right, color: AppColors.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
