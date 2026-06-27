import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('reservili');

  final container = ProviderContainer();
  await container.read(localeProvider.notifier).loadSaved();
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ReserviliApp(),
    ),
  );
}
