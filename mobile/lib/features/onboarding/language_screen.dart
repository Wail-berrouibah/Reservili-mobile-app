import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/locale_provider.dart';
import '../../shared/widgets/soft_card.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.translate,
                  size: 56, color: AppColors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text('Choisissez votre langue',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text('اختر لغتك',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.xxl),
              _option(context, ref, const Locale('fr'), 'Français', '🇫🇷'),
              const SizedBox(height: AppSpacing.md),
              _option(context, ref, const Locale('ar'), 'العربية', '🇩🇿'),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, WidgetRef ref, Locale locale,
      String label, String flag) {
    return SoftCard(
      onTap: () async {
        await ref.read(localeProvider.notifier).setLocale(locale);
        if (context.mounted) context.go(AppRoutes.accessCode);
      },
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
