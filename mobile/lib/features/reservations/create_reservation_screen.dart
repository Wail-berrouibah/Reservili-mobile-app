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
import '../../shared/models/reservation_model.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/reservation_date_picker.dart';

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
  final _price = TextEditingController();

  String? _selectedHomeId;
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  TimeOfDay _checkInTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 10, minute: 0);
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
    _price.dispose();
    super.dispose();
  }

  Set<DateTime> _computeReservedDates(List<ReservationModel> reservations) {
    if (_selectedHomeId == null) return {};
    final homeReservations =
        reservations.where((r) => r.homeId == _selectedHomeId && r.isActive);
    final dates = <DateTime>{};
    for (final r in homeReservations) {
      var d = DateTime(
        r.checkInDate.year,
        r.checkInDate.month,
        r.checkInDate.day,
      );
      final checkOutDay =
          DateTime(r.checkOutDate.year, r.checkOutDate.month, r.checkOutDate.day);
      while (d.isBefore(checkOutDay)) {
        dates.add(d);
        d = d.add(const Duration(days: 1));
      }
    }
    return dates;
  }

  Set<DateTime> _checkInDates(List<ReservationModel> reservations) {
    if (_selectedHomeId == null) return {};
    return reservations
        .where((r) => r.homeId == _selectedHomeId && r.isActive)
        .map((r) => DateTime(r.checkInDate.year, r.checkInDate.month, r.checkInDate.day))
        .toSet();
  }

  Set<DateTime> _checkOutDates(List<ReservationModel> reservations) {
    if (_selectedHomeId == null) return {};
    return reservations
        .where((r) => r.homeId == _selectedHomeId && r.isActive)
        .map((r) => DateTime(r.checkOutDate.year, r.checkOutDate.month, r.checkOutDate.day))
        .toSet();
  }

  void _onDayTap(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day.isBefore(today)) return;

    if (_selectedStart == null || (_selectedStart != null && _selectedEnd != null)) {
      _selectedStart = day;
      _selectedEnd = null;
    } else if (_selectedEnd == null) {
      if (day.isBefore(_selectedStart!)) {
        _selectedStart = day;
        _selectedEnd = null;
      } else {
        _selectedEnd = day;
      }
    }
    setState(() {});
  }

  Future<void> _pickCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime,
    );
    if (picked != null) setState(() => _checkInTime = picked);
  }

  Future<void> _pickCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime,
    );
    if (picked != null) setState(() => _checkOutTime = picked);
  }

  DateTime _combine(DateTime date, TimeOfDay time) => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

  DateTime _resolveCheckOut() {
    final end = _selectedEnd!;
    return _combine(end.add(const Duration(days: 1)), _checkOutTime);
  }

  double _parsePrice() {
    final text = _price.text.trim();
    final cleaned = text.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _submit(AppLocalizations t) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStart == null || _selectedEnd == null) {
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
            checkIn: _combine(_selectedStart!, _checkInTime),
            checkOut: _resolveCheckOut(),
            guestsCount: int.tryParse(_guests.text.trim()) ?? 1,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            paidPrice: _parsePrice(),
          );
      if (mounted) {
        _snack(t.reservationCreated);
        context.pop();
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      if (e.toString().contains('GAP_NOT_ALLOWED')) {
        if (!mounted) return;
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Jour non réservé'),
            content: const Text(
                'Il y a un jour vide entre cette réservation et une autre. Voulez-vous continuer ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Continuer'),
              ),
            ],
          ),
        );
        if (ok == true) {
          setState(() => _saving = true);
          try {
            await ref.read(reservationsProvider.notifier).createReservation(
                  homeId: _selectedHomeId!,
                  guestName: _name.text.trim(),
                  guestPhone: _phone.text.trim(),
                  guestEmail:
                      _email.text.trim().isEmpty ? null : _email.text.trim(),
                  checkIn: _combine(_selectedStart!, _checkInTime),
                  checkOut: _resolveCheckOut(),
                  guestsCount: int.tryParse(_guests.text.trim()) ?? 1,
                  notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                  paidPrice: _parsePrice(),
                  allowGap: true,
                );
            if (mounted) {
              _snack(t.reservationCreated);
              context.pop();
            }
          } catch (e2) {
            if (mounted) {
              _snack(e2.toString().contains('DATES_UNAVAILABLE')
                  ? t.datesUnavailable
                  : '${e2}');
            }
          } finally {
            if (mounted) setState(() => _saving = false);
          }
        }
      } else {
        if (mounted) _snack(t.datesUnavailable);
      }
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
    final reservationsAsync = ref.watch(reservationsProvider);

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
              onChanged: (v) {
                setState(() {
                  _selectedHomeId = v;
                  _selectedStart = null;
                  _selectedEnd = null;
                });
              },
              validator: (v) => v == null ? t.chooseHome : null,
            ),
            if (_selectedHomeId != null) ...[
              const SizedBox(height: AppSpacing.lg),
              reservationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (reservations) {
                  final reservedDates = _computeReservedDates(reservations);
                  final checkInDates = _checkInDates(reservations);
                  final checkOutDates = _checkOutDates(reservations);
                  return ReservationDatePicker(
                    reservedDates: reservedDates,
                    checkInDates: checkInDates,
                    checkOutDates: checkOutDates,
                    selectedStart: _selectedStart,
                    selectedEnd: _selectedEnd,
                    onDayTap: _onDayTap,
                    selectable: true,
                    showLegend: true,
                    reservedAsOccupied: true,
                  );
                },
              ),
              if (_selectedStart != null && _selectedEnd != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    AppDateUtils.rangeLabel(_selectedStart!, _selectedEnd!),
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: t.arrival,
                      time: _checkInTime,
                      onTap: _pickCheckInTime,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TimeTile(
                      label: t.departure,
                      time: _checkOutTime,
                      onTap: _pickCheckOutTime,
                    ),
                  ),
                ],
              ),
            ],
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
              label: 'Prix payé (DA)',
              controller: _price,
              keyboardType: TextInputType.number,
              hint: 'ex: 5000',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Prix payé requis';
                final cleaned = v.trim().replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
                final parsed = double.tryParse(cleaned);
                if (parsed == null || parsed < 0) return 'Montant invalide';
                return null;
              },
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

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = time.format(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Text(display, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}
