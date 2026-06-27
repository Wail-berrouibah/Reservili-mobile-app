import '../../shared/models/reservation_model.dart';

/// Core booking rules: a home cannot have two active reservations
/// that overlap on the same dates.
class ReservationUtils {
  ReservationUtils._();

  /// [hasOverlap] with pre-filtered list (no homeId / ignoreReservationId).
  static bool hasOverlap(
    List<ReservationModel> reservations,
    DateTime checkIn,
    DateTime checkOut,
  ) {
    for (final r in reservations) {
      if (!r.isActive) continue;
      if (r.checkInDate.isBefore(checkOut) &&
          r.checkOutDate.isAfter(checkIn)) {
        return true;
      }
    }
    return false;
  }

  /// A home is available when there is no overlapping active reservation.
  static bool isHomeAvailable(
    List<ReservationModel> reservations,
    String homeId,
    DateTime checkIn,
    DateTime checkOut,
  ) {
    final homeReservations = reservations.where((r) => r.homeId == homeId);
    return !hasOverlap(homeReservations.toList(), checkIn, checkOut);
  }

  /// Basic guard for valid date ranges (check-in must be before check-out).
  static bool isValidRange(DateTime checkIn, DateTime checkOut) {
    return checkIn.isBefore(checkOut);
  }
}
