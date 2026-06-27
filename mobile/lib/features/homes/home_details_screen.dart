import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/homes_provider.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/soft_card.dart';

class HomeDetailsScreen extends ConsumerWidget {
  final String homeId;
  const HomeDetailsScreen({super.key, required this.homeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final homesAsync = ref.watch(homesProvider);

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

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
                      t.pricePerNight(home.pricePerNight.toStringAsFixed(0)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: t.book,
                icon: Icons.event_available_outlined,
                onPressed: () => context.push(
                  AppRoutes.createReservation,
                  extra: home.id,
                ),
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
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}
