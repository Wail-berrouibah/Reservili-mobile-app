import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('reservili');

  final container = ProviderContainer();
  await container.read(localeProvider.notifier).loadSaved();

  // Notifications only supported on Android/iOS
  if (!kIsWeb) {
    NotificationService.onNotificationTap = (_) {};
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermissions();
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ReserviliApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final payload = NotificationService.instance.consumePendingPayload();
    if (payload != null) {
      appRouter.go('/reservations/details', extra: payload);
    }
  });
}
