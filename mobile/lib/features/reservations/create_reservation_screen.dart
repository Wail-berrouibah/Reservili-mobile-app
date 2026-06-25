import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../shared/models/home_model.dart';
import '../../shared/models/guest_model.dart';
import '../../shared/models/reservation_model.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/soft_card.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _guestEmailController = TextEditingController();
  final _notesController = TextEditingController();

  HomeModel? _selectedHome;
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is HomeModel) {
        setState(() => _selectedHome = extra);
      }
    });
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _guestEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _checkIn != null && _checkOut != null
          ? DateTimeRange(start: _checkIn!, end: _checkOut!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
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
      _checkDoubleBooking();
    }
  }

  void _checkDoubleBooking() {
    if (_selectedHome == null || _checkIn == null || _checkOut == null) return;

    final provider = context.read<ReservationsProvider>();
    final hasOverlap = provider.hasOverlap(
      _selectedHome!.id,
      _checkIn!,
      _checkOut!,
    );

    if (hasOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This home is already booked for those dates'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a home'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
      return;
    }
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select dates'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
      return;
    }

    if (context.read<ReservationsProvider>().hasOverlap(
      _selectedHome!.id,
      _checkIn!,
      _checkOut!,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot book — dates overlap with an existing reservation'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
      return;
    }

    final reservation = ReservationModel(
      homeId: _selectedHome!.id,
      guest: GuestModel(
        name: _guestNameController.text.trim(),
        phone: _guestPhoneController.text.trim().isEmpty ? null : _guestPhoneController.text.trim(),
        email: _guestEmailController.text.trim().isEmpty ? null : _guestEmailController.text.trim(),
      ),
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    context.read<ReservationsProvider>().addReservation(reservation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reservation created for ${_selectedHome!.name}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final homesProvider = context.watch<HomesProvider>();
    final availableHomes = homesProvider.homes;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('New Reservation')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Home', style: AppTextStyles.title3),
                const SizedBox(height: AppSpacing.md),
                _buildHomeSelector(availableHomes),
                const SizedBox(height: AppSpacing.xxl),
                Text('Select Dates', style: AppTextStyles.title3),
                const SizedBox(height: AppSpacing.md),
                _buildDateSelector(),
                const SizedBox(height: AppSpacing.xxl),
                Text('Guest Information', style: AppTextStyles.title3),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Full Name',
                  hint: 'Guest name',
                  controller: _guestNameController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Guest name is required';
                    if (v.trim().length < 2) return 'Name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Phone',
                        hint: '+1 555-0100',
                        controller: _guestPhoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            if (!RegExp(r'^\+?[\d\s\-()]{7,15}$').hasMatch(v.trim())) {
                              return 'Invalid phone';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: AppTextField(
                        label: 'Email',
                        hint: 'guest@email.com',
                        controller: _guestEmailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Notes (optional)',
                  hint: 'Any special requests...',
                  controller: _notesController,
                  maxLines: 2,
                ),
                if (_selectedHome != null && _checkIn != null && _checkOut != null) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  _buildPriceSummary(),
                ],
                const SizedBox(height: AppSpacing.xxl * 2),
                PrimaryButton(
                  label: 'Create Reservation',
                  icon: Icons.check_circle_outline,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeSelector(List<HomeModel> homes) {
    return SoftCard(
      onTap: () => _showHomePicker(homes),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              _selectedHome != null ? Icons.home_rounded : Icons.home_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedHome?.name ?? 'Choose a home',
                  style: AppTextStyles.headline.copyWith(
                    color: _selectedHome != null ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                if (_selectedHome != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '\$${_selectedHome!.pricePerNight.toStringAsFixed(0)} / night • ${_selectedHome!.maxGuests} guests',
                    style: AppTextStyles.footnote,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  void _showHomePicker(List<HomeModel> homes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Select a Home', style: AppTextStyles.title3),
              const SizedBox(height: AppSpacing.lg),
              ...homes.map((home) => ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.home_outlined, color: AppColors.primary),
                ),
                title: Text(home.name, style: AppTextStyles.headline),
                subtitle: Text(
                  '\$${home.pricePerNight.toStringAsFixed(0)}/night',
                  style: AppTextStyles.footnote,
                ),
                trailing: _selectedHome?.id == home.id
                    ? Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedHome = home);
                  Navigator.pop(ctx);
                  _checkDoubleBooking();
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return SoftCard(
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
                if (_checkIn != null && _checkOut != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${du.DateUtils.nightsBetween(_checkIn!, _checkOut!)} nights',
                    style: AppTextStyles.footnote,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final nights = du.DateUtils.nightsBetween(_checkIn!, _checkOut!);
    final total = nights * _selectedHome!.pricePerNight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price per night', style: AppTextStyles.callout),
              Text('\$${_selectedHome!.pricePerNight.toStringAsFixed(0)}', style: AppTextStyles.callout),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Number of nights', style: AppTextStyles.callout),
              Text('$nights', style: AppTextStyles.callout),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.headline),
              Text('\$${total.toStringAsFixed(0)}', style: AppTextStyles.title2.copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
