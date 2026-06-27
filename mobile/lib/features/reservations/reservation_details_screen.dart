import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/guests_provider.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/models/guest_model.dart';
import '../../shared/models/reservation_model.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/reservation_timeline.dart';
import '../../shared/widgets/soft_card.dart';
import '../../shared/widgets/status_badge.dart';

const _delete = 'Supprimer la réservation';
const _deleteConfirmTitle = 'Supprimer la réservation ?';
const _deleteConfirmBody = 'Cette action est définitive.';

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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(_deleteConfirmTitle),
        content: const Text(_deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
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
      await ref
          .read(reservationsProvider.notifier)
          .deleteReservation(reservationId);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final reservationsAsync = ref.watch(reservationsProvider);
    final homes = ref.watch(homesProvider).asData?.value ?? [];
    final guestsAsync = ref.watch(guestsProvider);

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
              ReservationTimeline(
                checkInDate: r.checkInDate,
                checkOutDate: r.checkOutDate,
              ),
              const SizedBox(height: AppSpacing.xl),
              _clientCard(guestsAsync, r.guestId, t),
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
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _delete,
                variant: ButtonVariant.danger,
                icon: Icons.delete_outline,
                onPressed: () => _confirmDelete(context, ref),
              ),
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

  Widget _clientCard(
    AsyncValue<List<GuestModel>> guestsAsync,
    String guestId,
    AppLocalizations t,
  ) {
    return guestsAsync.when(
      loading: () => const SoftCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.client, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('—', style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
      data: (guests) {
        final match = guests.where((g) => g.id == guestId).toList();
        final guest = match.isNotEmpty ? match.first : null;

        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.client, style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: AppSpacing.iconSm,
                      color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    guest?.fullName ?? '—',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: AppSpacing.iconSm,
                      color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    guest?.phone ?? '—',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
              if (guest?.email != null && guest!.email!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        size: AppSpacing.iconSm,
                        color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        guest.email!,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
