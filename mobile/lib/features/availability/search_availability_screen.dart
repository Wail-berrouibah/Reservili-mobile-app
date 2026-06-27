import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/home_card.dart';

class SearchAvailabilityScreen extends ConsumerStatefulWidget {
  const SearchAvailabilityScreen({super.key});

  @override
  ConsumerState<SearchAvailabilityScreen> createState() =>
      _SearchAvailabilityScreenState();
}

class _SearchAvailabilityScreenState
    extends ConsumerState<SearchAvailabilityScreen> {
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
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
              onTap: _pickRange,
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
                    const Icon(Icons.calendar_month_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _range == null
                            ? t.chooseDates
                            : AppDateUtils.rangeLabel(
                                _range!.start, _range!.end),
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _range == null
                  ? EmptyState(
                      icon: Icons.calendar_today_outlined,
                      title: t.chooseDates,
                      message: '',
                    )
                  : Consumer(
                      builder: (context, ref, _) {
                        final availableAsync = ref.watch(
                          availableHomesProvider(
                            DateRange(_range!.start, _range!.end),
                          ),
                        );
                        return availableAsync.when(
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('$e')),
                          data: (homes) {
                            if (homes.isEmpty) {
                              return EmptyState(
                                icon: Icons.search_off_outlined,
                                title: t.noHomesAvailable,
                                message: t.tryOtherDates,
                              );
                            }
                            return ListView.separated(
                              itemCount: homes.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (_, i) {
                                final home = homes[i];
                                return HomeCard(
                                  home: home,
                                  onTap: () => context.push(
                                    AppRoutes.createReservation,
                                    extra: home.id,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
