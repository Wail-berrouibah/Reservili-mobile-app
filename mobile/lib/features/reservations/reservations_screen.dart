import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/reservation_card.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final reservationsAsync = ref.watch(reservationsProvider);
    final homes = ref.watch(homesProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(t.reservations)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(reservationsProvider),
        child: reservationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (reservations) {
            if (reservations.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: t.noReservations,
                    message: t.upcomingReservationsHint,
                  ),
                ],
              );
            }
            final sorted = [...reservations]
              ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: sorted.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final r = sorted[i];
                final match = homes.where((h) => h.id == r.homeId);
                final homeName =
                    match.isNotEmpty ? match.first.name : t.home;
                return ReservationCard(
                  reservation: r,
                  homeName: homeName,
                  guestName: t.client,
                  onTap: () => context.push(
                    AppRoutes.reservationDetails,
                    extra: r.id,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.availability),
        child: const Icon(Icons.add),
      ),
    );
  }
}
