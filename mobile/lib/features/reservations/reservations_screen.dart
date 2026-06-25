import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/reservation_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../providers/reservations_provider.dart';
import '../../providers/homes_provider.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Upcoming', 'Past'];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Reservations'),
          actions: [
            IconButton(
              onPressed: () => context.push('/reservations/create'),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterChips(),
            Expanded(child: _buildReservationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: List.generate(_filters.length, (i) {
          final isSelected = _selectedFilter == i;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: AppColors.divider),
                ),
                child: Text(
                  _filters[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReservationsList() {
    return Consumer2<ReservationsProvider, HomesProvider>(
      builder: (context, resProvider, homesProvider, _) {
        var reservations = resProvider.reservations;

        if (_selectedFilter == 1) {
          reservations = reservations.where((r) => r.checkIn.isAfter(DateTime.now())).toList();
        } else if (_selectedFilter == 2) {
          reservations = reservations.where((r) => r.checkIn.isBefore(DateTime.now())).toList();
        }

        reservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        for (final r in reservations) {
          final home = homesProvider.getHomeById(r.homeId);
          if (home != null) r..withHome(home);
        }

        if (reservations.isEmpty) {
          return EmptyState(
            icon: Icons.calendar_month_outlined,
            title: 'No reservations',
            subtitle: _selectedFilter == 0
                ? 'Create your first reservation'
                : 'No reservations match this filter',
            actionLabel: _selectedFilter == 0 ? 'New Reservation' : null,
            onAction: _selectedFilter == 0
                ? () => context.push('/reservations/create')
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final r = reservations[index];
              return ReservationCard(
                reservation: r,
                onTap: () => context.push('/reservations/${r.id}'),
              );
            },
          ),
        );
      },
    );
  }
}
