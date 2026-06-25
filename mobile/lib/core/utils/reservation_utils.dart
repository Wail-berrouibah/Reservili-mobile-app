enum ReservationStatus {
  confirmed,
  rescheduled,
  cancelled;

  String get label {
    switch (this) {
      case ReservationStatus.confirmed:
        return 'Confirmed';
      case ReservationStatus.rescheduled:
        return 'Rescheduled';
      case ReservationStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get localizedLabel {
    switch (this) {
      case ReservationStatus.confirmed:
        return 'Confirmée';
      case ReservationStatus.rescheduled:
        return 'Reportée';
      case ReservationStatus.cancelled:
        return 'Annulée';
    }
  }
}

class ReservationUtils {
  ReservationUtils._();

  static String formatStatus(ReservationStatus status) {
    return status.label;
  }

  static bool canReschedule(ReservationStatus status) {
    return status == ReservationStatus.confirmed;
  }

  static bool canCancel(ReservationStatus status) {
    return status != ReservationStatus.cancelled;
  }
}
