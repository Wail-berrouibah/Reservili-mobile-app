import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('app_locale');
    final token = prefs.getString('auth_token');

    if (!mounted) return;
    if (savedLocale == null) {
      context.go(AppRoutes.language);
    } else if (token != null) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.accessCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: const Icon(Icons.home_rounded,
                  color: Colors.white, size: 48),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Reservili',
                style:
                    AppTextStyles.displayLarge.copyWith(color: Colors.white)),
            const SizedBox(height: AppSpacing.sm),
            Text('Gestion des réservations',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Colors.white.withOpacity(0.8))),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
