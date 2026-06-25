import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/language_provider.dart';
import '../../core/localization/supported_locales.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/soft_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildSectionHeader('Language'),
            const SizedBox(height: AppSpacing.md),
            _buildLanguageSection(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildSectionHeader('About'),
            const SizedBox(height: AppSpacing.md),
            SoftCard(
              child: Column(
                children: [
                  _buildSettingTile(Icons.info_outline, 'Version', '1.0.0'),
                  const Divider(height: 1, indent: 56),
                  _buildSettingTile(Icons.code_outlined, 'Built with', 'Flutter'),
                  const Divider(height: 1, indent: 56),
                  _buildSettingTile(Icons.palette_outlined, 'Design', 'Apple-style'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.title3);
  }

  Widget _buildLanguageSection(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    return SoftCard(
      child: Column(
        children: SupportedLocales.locales.map((locale) {
          final isSelected = langProvider.locale == locale;
          return Column(
            children: [
              if (locale != SupportedLocales.locales.first)
                const Divider(height: 1, indent: 56),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _getFlag(locale.languageCode),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                title: Text(
                  SupportedLocales.getLocaleName(locale),
                  style: AppTextStyles.body,
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppColors.primary, size: 22)
                    : null,
                onTap: () {
                  langProvider.setLocale(locale);
                  context.pop();
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.body),
      trailing: Text(
        subtitle,
        style: AppTextStyles.footnote.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  String _getFlag(String languageCode) {
    switch (languageCode) {
      case 'en': return '🇬🇧';
      case 'fr': return '🇫🇷';
      case 'ar': return '🇸🇦';
      default: return '🌐';
    }
  }
}
