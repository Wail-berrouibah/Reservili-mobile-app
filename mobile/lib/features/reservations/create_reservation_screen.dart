import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';
import '../../providers/homes_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';

class CreateReservationScreen extends ConsumerStatefulWidget {
  final String? homeId;
  const CreateReservationScreen({super.key, this.homeId});

  @override
  ConsumerState<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState
    extends ConsumerState<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _guests = TextEditingController(text: '1');
  final _notes = TextEditingController();

  String? _selectedHomeId;
  DateTimeRange? _range;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedHomeId = widget.homeId;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _guests.dispose();
    _notes.dispose();
    super.dispose();
  }

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

  Future<void> _submit(AppLocalizations t) async {
    if (!_formKey.currentState!.validate()) return;
    if (_range == null) {
      _snack(t.invalidDates);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(reservationsProvider.notifier).createReservation(
            homeId: _selectedHomeId!,
            guestName: _name.text.trim(),
            guestPhone: _phone.text.trim(),
            guestEmail:
                _email.text.trim().isEmpty ? null : _email.text.trim(),
            checkIn: _range!.start,
            checkOut: _range!.end,
            guestsCount: int.tryParse(_guests.text.trim()) ?? 1,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      if (mounted) {
        _snack(t.reservationCreated);
        context.pop();
      }
    } catch (e) {
      final msg = e.toString().contains('GAP_NOT_ALLOWED')
          ? t.gapWarning
          : t.datesUnavailable;
      if (mounted) _snack(msg);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final homes = ref.watch(homesProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(t.newReservation)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(t.home, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedHomeId,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              items: homes
                  .map((h) => DropdownMenuItem(
                        value: h.id,
                        child: Text(h.name),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedHomeId = v),
              validator: (v) => v == null ? t.chooseHome : null,
            ),
            const SizedBox(height: AppSpacing.lg),
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
            AppTextField(
              label: t.guestName,
              controller: _name,
              validator: (v) => Validators.required(v, t.required),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: t.phone,
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  Validators.phone(v, t.phoneRequired, t.invalidPhone),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: t.emailOptional,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => Validators.email(v, t.invalidEmail),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: t.guestsCount,
              controller: _guests,
              keyboardType: TextInputType.number,
              validator: (v) => Validators.positiveNumber(v, t.invalidValue),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: t.notesOptional,
              controller: _notes,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: t.confirmReservation,
              loading: _saving,
              onPressed: () => _submit(t),
            ),
          ],
        ),
      ),
    );
  }
}
