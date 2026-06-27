import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../providers/homes_provider.dart';
import '../../shared/models/home_model.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';

class AddHomeScreen extends ConsumerStatefulWidget {
  final HomeModel? home;
  const AddHomeScreen({super.key, this.home});

  @override
  ConsumerState<AddHomeScreen> createState() => _AddHomeScreenState();
}

class _AddHomeScreenState extends ConsumerState<AddHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _capacity = TextEditingController();
  final _price = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final h = widget.home;
    if (h != null) {
      _name.text = h.name;
      _location.text = h.location;
      _capacity.text = h.capacity.toString();
      _price.text = h.pricePerNight.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _capacity.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final existing = widget.home;
    final id = existing?.id ?? 'h${DateTime.now().millisecondsSinceEpoch}';
    final home = HomeModel(
      id: id,
      name: _name.text.trim(),
      location: _location.text.trim(),
      capacity: int.parse(_capacity.text.trim()),
      pricePerNight: double.parse(_price.text.trim()),
      status: existing?.status ?? HomeStatus.available,
    );

    if (existing != null) {
      await ref.read(homesProvider.notifier).updateHome(home);
    } else {
      await ref.read(homesProvider.notifier).addHome(home);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isEditing = widget.home != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? t.homeDetails : t.addHome)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              label: t.name,
              controller: _name,
              validator: (v) => Validators.required(v, t.required),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: t.location,
              controller: _location,
              validator: (v) => Validators.required(v, t.required),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: t.capacity,
              controller: _capacity,
              keyboardType: TextInputType.number,
              validator: (v) => Validators.positiveNumber(v, t.invalidValue),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: t.pricePerNightLabel,
              controller: _price,
              keyboardType: TextInputType.number,
              validator: (v) => Validators.positiveNumber(v, t.invalidValue),
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: t.save,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
