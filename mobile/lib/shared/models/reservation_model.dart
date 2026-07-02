enum ReservationStatus { pending, confirmed, cancelled }

class ReservationModel {
  final String id;
  final String homeId;
  final String guestId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestsCount;
  final ReservationStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReservationModel({
    required this.id,
    required this.homeId,
    required this.guestId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestsCount,
    this.status = ReservationStatus.pending,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Number of nights for this reservation.
  int get nights {
    final inDate = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    final outDate = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    return outDate.difference(inDate).inDays;
  }

  /// A reservation still blocks a home unless it is cancelled.
  bool get isActive => status != ReservationStatus.cancelled;

  /// True if this reservation's dates overlap the given range.
  bool overlaps(DateTime otherCheckIn, DateTime otherCheckOut) {
    return checkInDate.isBefore(otherCheckOut) &&
        checkOutDate.isAfter(otherCheckIn);
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      ReservationModel(
        id: json['id'] as String,
        homeId: json['homeId'] as String,
        guestId: json['guestId'] as String,
        checkInDate: DateTime.parse(json['checkInDate'] as String),
        checkOutDate: DateTime.parse(json['checkOutDate'] as String),
        guestsCount: json['guestsCount'] as int,
        status: ReservationStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ReservationStatus.pending,
        ),
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'homeId': homeId,
        'guestId': guestId,
        'checkInDate': checkInDate.toIso8601String(),
        'checkOutDate': checkOutDate.toIso8601String(),
        'guestsCount': guestsCount,
        'status': status.name,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  ReservationModel copyWith({
    String? id,
    String? homeId,
    String? guestId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guestsCount,
    ReservationStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      guestId: guestId ?? this.guestId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guestsCount: guestsCount ?? this.guestsCount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
