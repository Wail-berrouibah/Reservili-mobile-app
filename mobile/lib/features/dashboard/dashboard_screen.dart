import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/reservation_card.dart';
import 'widgets/dashboard_stat_card.dart';
import 'widgets/quick_action_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final homesAsync = ref.watch(homesProvider);
    final reservationsAsync = ref.watch(reservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homesProvider);
          ref.invalidate(reservationsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(t.dashboard, style: AppTextStyles.headingLarge),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.home_work_outlined,
                    label: t.homes,
                    value: homesAsync.maybeWhen(
                      data: (h) => '${h.length}',
                      orElse: () => '—',
                    ),
                    onTap: () => context.push(AppRoutes.homes),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.event_available_outlined,
                    label: t.reservations,
                    color: AppColors.accent,
                    value: reservationsAsync.maybeWhen(
                      data: (r) => '${r.where((e) => e.isActive).length}',
                      orElse: () => '—',
                    ),
                    onTap: () => context.push(AppRoutes.reservations),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(t.quickActions, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.search,
                    label: t.availability,
                    onTap: () => context.push(AppRoutes.availability),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.add_home_outlined,
                    label: t.add,
                    onTap: () => context.push(AppRoutes.addHome),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.list_alt_outlined,
                    label: t.reservations,
                    onTap: () => context.push(AppRoutes.reservations),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(t.recentReservations, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            reservationsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('$e'),
              data: (reservations) {
                final active = reservations.where((r) => r.isActive).toList()
                  ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

                if (active.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: t.noReservations,
                    message: t.upcomingReservationsHint,
                  );
                }

                final homes = homesAsync.asData?.value ?? [];
                return Column(
                  children: active.take(5).map((r) {
                    final match = homes.where((h) => h.id == r.homeId);
                    final homeName =
                        match.isNotEmpty ? match.first.name : t.home;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ReservationCard(
                        reservation: r,
                        homeName: homeName,
                        guestName: t.client,
                        onTap: () => context.push(
                          AppRoutes.reservationDetails,
                          extra: r.id,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.availability),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(t.book),
      ),
    );
  }
}
