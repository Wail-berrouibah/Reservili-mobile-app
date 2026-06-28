import 'package:reservili/generated/app_localizations.dart';

import '../../shared/models/home_model.dart';
import '../../shared/models/reservation_model.dart';
import 'notification_service.dart';

class ReservationReminderScheduler {
  ReservationReminderScheduler._();

  static Future<void> sync({
    required List<ReservationModel> reservations,
    required List<HomeModel> homes,
    required AppLocalizations t,
  }) async {
    final service = NotificationService.instance;
    await service.cancelAll();

    for (final r in reservations) {
      if (r.status == ReservationStatus.cancelled) continue;

      final checkout = r.checkOutDate;
      final remindAt = DateTime(
        checkout.year,
        checkout.month,
        checkout.day,
        9,
      ).subtract(const Duration(days: 1));

      if (remindAt.isBefore(DateTime.now())) continue;

      final match = homes.where((h) => h.id == r.homeId);
      final homeName = match.isNotEmpty ? match.first.name : t.home;

      await service.scheduleReminder(
        id: r.id.hashCode,
        when: remindAt,
        title: t.reminderTitle,
        body: t.reservationEndsTomorrow(homeName),
        payload: r.id,
      );
    }
  }
}
