import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../shared/models/home_model.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/soft_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';

class SearchAvailabilityScreen extends StatefulWidget {
  const SearchAvailabilityScreen({super.key});

  @override
  State<SearchAvailabilityScreen> createState() => _SearchAvailabilityScreenState();
}

class _SearchAvailabilityScreenState extends State<SearchAvailabilityScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  List<HomeModel> _availableHomes = [];
  bool _hasSearched = false;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (result != null) {
      setState(() {
        _checkIn = result.start;
        _checkOut = result.end;
      });
    }
  }

  void _search() {
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select dates first'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
      return;
    }

    final homesProvider = context.read<HomesProvider>();
    final resProvider = context.read<ReservationsProvider>();
    final allHomes = homesProvider.homes;

    setState(() {
      _availableHomes = allHomes.where((home) {
        final hasOverlap = resProvider.hasOverlap(home.id, _checkIn!, _checkOut!);
        return !hasOverlap && home.isAvailable;
      }).toList();
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Check Availability')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Dates', style: AppTextStyles.title3),
              const SizedBox(height: AppSpacing.md),
              SoftCard(
                onTap: _pickDateRange,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _checkIn != null && _checkOut != null
                                ? du.DateUtils.formatDateRange(_checkIn!, _checkOut!)
                                : 'Select check-in & check-out dates',
                            style: AppTextStyles.headline.copyWith(
                              color: _checkIn != null ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                          if (_checkIn != null && _checkOut != null)
                            Text(
                              '${du.DateUtils.nightsBetween(_checkIn!, _checkOut!)} nights',
                              style: AppTextStyles.footnote,
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Search Available Homes',
                icon: Icons.search_outlined,
                onPressed: _search,
              ),
              if (_hasSearched) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Available Homes',
                  style: AppTextStyles.title3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${_availableHomes.length} homes available for your dates',
                  style: AppTextStyles.subheadline,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_availableHomes.isEmpty)
                  EmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No homes available',
                    subtitle: 'Try different dates or check back later',
                  )
                else
                  ..._availableHomes.map((home) => _buildHomeResult(home)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeResult(HomeModel home) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SoftCard(
        onTap: () => context.push('/homes/${home.id}'),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(home.name, style: AppTextStyles.headline),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '\$${home.pricePerNight.toStringAsFixed(0)}/night • ${home.maxGuests} guests',
                    style: AppTextStyles.footnote,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
