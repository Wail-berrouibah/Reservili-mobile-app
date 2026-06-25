import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';
import 'widgets/dashboard_stat_card.dart';
import 'widgets/quick_action_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xxl),
                _buildStatsRow(context),
                const SizedBox(height: AppSpacing.xxl),
                _buildQuickActions(context),
                const SizedBox(height: AppSpacing.xxl),
                _buildUpcomingSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: AppTextStyles.title2,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Manage your home reservations',
              style: AppTextStyles.subheadline,
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined, size: 20),
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final homesProvider = context.watch<HomesProvider>();
    final reservationsProvider = context.watch<ReservationsProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;
        final children = [
          Expanded(
            child: DashboardStatCard(
              label: 'Total Homes',
              value: '${homesProvider.totalHomes}',
              icon: Icons.home_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: DashboardStatCard(
              label: 'Available',
              value: '${homesProvider.availableHomes}',
              icon: Icons.check_circle_outline,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: DashboardStatCard(
              label: 'Upcoming',
              value: '${reservationsProvider.upcomingCount}',
              icon: Icons.calendar_today_outlined,
              color: AppColors.warning,
            ),
          ),
        ];

        if (isWide) {
          return Row(children: children);
        }
        return Row(children: children);
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.title3),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                label: 'Browse\nHomes',
                icon: Icons.search_outlined,
                color: AppColors.primary,
                onTap: () => context.go('/homes'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: QuickActionCard(
                label: 'New\nReservation',
                icon: Icons.add_circle_outline,
                color: AppColors.success,
                onTap: () => context.push('/reservations/create'),
              ),
            ),
            Expanded(
              child: QuickActionCard(
                label: 'Check\nAvailability',
                icon: Icons.event_available_outlined,
                color: AppColors.warning,
                onTap: () => context.push('/availability'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    final reservationsProvider = context.watch<ReservationsProvider>();
    final upcoming = reservationsProvider.upcomingReservations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Reservations', style: AppTextStyles.title3),
            if (upcoming.isNotEmpty)
              GestureDetector(
                onTap: () => context.go('/reservations'),
                child: Text(
                  'See All',
                  style: AppTextStyles.callout.copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (upcoming.isEmpty)
          _buildEmptyUpcoming()
        else
          ...upcoming.take(3).map((r) => _buildUpcomingCard(context, r)),
      ],
    );
  }

  Widget _buildEmptyUpcoming() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text('No upcoming reservations', style: AppTextStyles.callout),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Create your first reservation to get started',
            style: AppTextStyles.footnote,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, dynamic reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Center(
              child: Icon(Icons.person_outline, color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.guest.name,
                  style: AppTextStyles.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  du.DateUtils.formatDateRange(reservation.checkIn, reservation.checkOut),
                  style: AppTextStyles.footnote,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppColors.confirmed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              '${reservation.nights} ngt',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.confirmed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
