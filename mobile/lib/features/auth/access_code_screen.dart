import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';
import 'widgets/code_input_field.dart';

class AccessCodeScreen extends ConsumerStatefulWidget {
  const AccessCodeScreen({super.key});

  @override
  ConsumerState<AccessCodeScreen> createState() => _AccessCodeScreenState();
}

class _AccessCodeScreenState extends ConsumerState<AccessCodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final ok =
        await ref.read(authProvider.notifier).verifyCode(_controller.text);
    if (ok && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: const Icon(Icons.lock_outline,
                      color: AppColors.primary, size: 42),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Bienvenue',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Entrez le code d'accès fourni par le propriétaire.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              CodeInputField(
                controller: _controller,
                errorText: auth.errorKey,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Continuer',
                loading: auth.loading,
                onPressed: _submit,
              ),
              const Spacer(),
              Text(
                'Ce code est lié à votre téléphone.',
                textAlign: TextAlign.center,
                style: AppTextStyles.label,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
