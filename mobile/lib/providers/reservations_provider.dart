import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/models/home_model.dart';
import '../shared/models/reservation_model.dart';
import 'guests_provider.dart';
import 'homes_provider.dart';
import 'repository_provider.dart';

class DateRange {
  final DateTime checkIn;
  final DateTime checkOut;
  const DateRange(this.checkIn, this.checkOut);

  @override
  bool operator ==(Object other) =>
      other is DateRange &&
      other.checkIn == checkIn &&
      other.checkOut == checkOut;

  @override
  int get hashCode => Object.hash(checkIn, checkOut);
}

final reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<ReservationModel>>(
        ReservationsNotifier.new);

class ReservationsNotifier extends AsyncNotifier<List<ReservationModel>> {
  @override
  Future<List<ReservationModel>> build() async {
    final repo = ref.read(repositoryProvider);
    return repo.getReservations();
  }

  Future<void> createReservation({
    required String homeId,
    required String guestName,
    required String guestPhone,
    String? guestEmail,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestsCount,
    String? notes,
  }) async {
    final repo = ref.read(repositoryProvider);
    await repo.createReservation(
      homeId: homeId,
      guestName: guestName,
      guestPhone: guestPhone,
      guestEmail: guestEmail,
      checkIn: checkIn,
      checkOut: checkOut,
      guestsCount: guestsCount,
      notes: notes,
    );
    ref.invalidate(guestsProvider);
    ref.invalidateSelf();
    await future;
  }

  Future<void> setStatus(String id, ReservationStatus status) async {
    final repo = ref.read(repositoryProvider);
    await repo.setStatus(id, status);
    ref.invalidateSelf();
    await future;
  }

  Future<void> reschedule(
      String id, DateTime checkIn, DateTime checkOut) async {
    final repo = ref.read(repositoryProvider);
    await repo.reschedule(id, checkIn, checkOut);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteReservation(String id) async {
    final repo = ref.read(repositoryProvider);
    await repo.deleteReservation(id);
    ref.invalidateSelf();
    await future;
  }
}

final availableHomesProvider =
    FutureProvider.family<List<HomeModel>, DateRange>((ref, range) async {
  final repo = ref.read(repositoryProvider);
  return repo.getAvailableHomes(range.checkIn, range.checkOut);
});

/// Structured calendar data: homeId → (date → active reservation or null if void).
class CalendarData {
  final Map<String, Map<DateTime, ReservationModel?>> entries;
  final List<HomeModel> homes;

  const CalendarData({required this.entries, required this.homes});
}

final calendarProvider =
    FutureProvider.family<CalendarData, DateTime>((ref, month) async {
  final repo = ref.read(repositoryProvider);
  final homes = await ref.watch(homesProvider.future);
  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 0);
  final data = await repo.getCalendarData(
    monthStart: monthStart,
    monthEnd: monthEnd,
  );
  return CalendarData(entries: data, homes: homes);
});
