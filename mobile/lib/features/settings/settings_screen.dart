import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../shared/widgets/soft_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tile(
                  icon: Icons.language,
                  title: t.language,
                  subtitle:
                      locale.languageCode == 'ar' ? 'العربية' : 'Français',
                  onTap: () => _showLanguageSheet(context, ref, locale),
                ),
                const Divider(height: 1),
                _tile(
                  icon: Icons.info_outline,
                  title: t.about,
                  subtitle: 'Reservili v1.0.0',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Reservili',
                    applicationVersion: '1.0.0',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.accessCode);
            },
            icon: const Icon(Icons.logout, color: AppColors.cancelled),
            label: Text(t.signOut,
                style: const TextStyle(color: AppColors.cancelled)),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(
      BuildContext context, WidgetRef ref, Locale current) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              trailing: current.languageCode == 'fr'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              trailing: current.languageCode == 'ar'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
