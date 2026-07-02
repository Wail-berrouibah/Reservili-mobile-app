import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservili/generated/app_localizations.dart';

import 'core/notifications/reservation_reminder_scheduler.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/homes_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/reservations_provider.dart';

class ReserviliApp extends ConsumerWidget {
  const ReserviliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Reservili',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent || event is KeyRepeatEvent) {
            if (event.character == null &&
                event.logicalKey == LogicalKeyboardKey.pageDown) {
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: _ReminderSync(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

class _ReminderSync extends ConsumerWidget {
  final Widget child;
  const _ReminderSync({required this.child});

  void _sync(WidgetRef ref, AppLocalizations t) {
    if (kIsWeb) return;
    final reservations = ref.read(reservationsProvider).asData?.value;
    final homes = ref.read(homesProvider).asData?.value;
    if (reservations != null && homes != null) {
      ReservationReminderScheduler.sync(
        reservations: reservations,
        homes: homes,
        t: t,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    ref.listen(reservationsProvider, (_, __) => _sync(ref, t));
    ref.listen(homesProvider, (_, __) => _sync(ref, t));
    _sync(ref, t);
    return child;
  }
}
