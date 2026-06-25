import 'package:flutter/foundation.dart';
import '../shared/models/reservation_model.dart';
import '../data/mock_data.dart';
import '../core/utils/reservation_utils.dart';

class ReservationsProvider extends ChangeNotifier {
  final List<ReservationModel> _reservations = [];

  List<ReservationModel> get reservations => List.unmodifiable(_reservations);

  int get totalReservations => _reservations.length;
  int get activeReservations =>
      _reservations.where((r) => r.status == ReservationStatus.confirmed).length;
  int get upcomingCount =>
      _reservations.where((r) =>
        r.status == ReservationStatus.confirmed &&
        r.checkIn.isAfter(DateTime.now())
      ).length;

  List<ReservationModel> get upcomingReservations {
    final sorted = List<ReservationModel>.from(_reservations);
    sorted.sort((a, b) => a.checkIn.compareTo(b.checkIn));
    return sorted.where((r) =>
      r.status == ReservationStatus.confirmed &&
      r.checkIn.isAfter(DateTime.now())
    ).toList();
  }

  List<ReservationModel> get recentReservations {
    final sorted = List<ReservationModel>.from(_reservations);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  void loadMockData() {
    _reservations.addAll(MockData.sampleReservations);
    notifyListeners();
  }

  List<ReservationModel> getReservationsForHome(String homeId) {
    return _reservations.where((r) => r.homeId == homeId).toList();
  }

  ReservationModel? getReservationById(String id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  bool hasOverlap(String homeId, DateTime checkIn, DateTime checkOut, [String? excludeId]) {
    return _reservations.any((r) =>
      r.homeId == homeId &&
      (excludeId == null || r.id != excludeId) &&
      r.status != ReservationStatus.cancelled &&
      checkIn.isBefore(r.checkOut) &&
      checkOut.isAfter(r.checkIn)
    );
  }

  void addReservation(ReservationModel reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }

  void updateReservation(ReservationModel reservation) {
    final index = _reservations.indexWhere((r) => r.id == reservation.id);
    if (index != -1) {
      _reservations[index] = reservation;
      notifyListeners();
    }
  }

  void cancelReservation(String id) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(
        status: ReservationStatus.cancelled,
      );
      notifyListeners();
    }
  }

  void rescheduleReservation(String id, DateTime newCheckIn, DateTime newCheckOut) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(
        checkIn: newCheckIn,
        checkOut: newCheckOut,
        status: ReservationStatus.rescheduled,
      );
      notifyListeners();
    }
  }
}
