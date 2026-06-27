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
import '../../shared/models/reservation_model.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/soft_card.dart';
import '../../shared/widgets/status_badge.dart';

class ReservationDetailsScreen extends ConsumerWidget {
  final String reservationId;
  const ReservationDetailsScreen({super.key, required this.reservationId});

  Future<void> _confirmCancel(
      BuildContext context, WidgetRef ref, AppLocalizations t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.cancelConfirmTitle),
        content: Text(t.cancelConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.yesCancel,
                style: const TextStyle(color: AppColors.cancelled)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(reservationsProvider.notifier)
          .setStatus(reservationId, ReservationStatus.cancelled);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final reservationsAsync = ref.watch(reservationsProvider);
    final homes = ref.watch(homesProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(t.reservationDetails)),
      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (reservations) {
          final match = reservations.where((r) => r.id == reservationId);
          if (match.isEmpty) {
            return Center(child: Text(t.reservationNotFound));
          }
          final r = match.first;
          final homeMatch = homes.where((h) => h.id == r.homeId);
          final homeName =
              homeMatch.isNotEmpty ? homeMatch.first.name : t.home;
          final isCancelled = r.status == ReservationStatus.cancelled;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child:
                        Text(homeName, style: AppTextStyles.headingLarge),
                  ),
                  StatusBadge(status: r.status),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SoftCard(
                child: Column(
                  children: [
                    _row(t.arrival, AppDateUtils.formatFull(r.checkInDate)),
                    const Divider(height: AppSpacing.lg),
                    _row(t.departure,
                        AppDateUtils.formatFull(r.checkOutDate)),
                    const Divider(height: AppSpacing.lg),
                    _row(t.nights, '${r.nights}'),
                    const Divider(height: AppSpacing.lg),
                    _row(t.personsLabel, '${r.guestsCount}'),
                    if (r.notes != null && r.notes!.isNotEmpty) ...[
                      const Divider(height: AppSpacing.lg),
                      _row(t.notes, r.notes!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (!isCancelled) ...[
                if (r.status == ReservationStatus.pending) ...[
                  PrimaryButton(
                    label: t.confirm,
                    icon: Icons.check_circle_outline,
                    onPressed: () => ref
                        .read(reservationsProvider.notifier)
                        .setStatus(r.id, ReservationStatus.confirmed),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                PrimaryButton(
                  label: t.reschedule,
                  variant: ButtonVariant.secondary,
                  icon: Icons.edit_calendar_outlined,
                  onPressed: () =>
                      context.push(AppRoutes.reschedule, extra: r.id),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: t.cancelReservation,
                  variant: ButtonVariant.danger,
                  icon: Icons.cancel_outlined,
                  onPressed: () => _confirmCancel(context, ref, t),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end, style: AppTextStyles.bodyLarge),
        ),
      ],
    );
  }
}
