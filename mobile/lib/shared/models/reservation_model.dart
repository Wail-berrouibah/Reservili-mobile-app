import 'package:uuid/uuid.dart';
import '../../core/utils/reservation_utils.dart';
import 'guest_model.dart';
import 'home_model.dart';

class ReservationModel {
  final String id;
  final String homeId;
  final GuestModel guest;
  final DateTime checkIn;
  final DateTime checkOut;
  final ReservationStatus status;
  final String? notes;
  final DateTime createdAt;

  ReservationModel({
    String? id,
    required this.homeId,
    required this.guest,
    required this.checkIn,
    required this.checkOut,
    this.status = ReservationStatus.confirmed,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  int get nights => checkOut.difference(checkIn).inDays;

  double get totalPrice {
    return nights * home.pricePerNight;
  }

  late final HomeModel home;

  ReservationModel withHome(HomeModel homeModel) {
    home = homeModel;
    return this;
  }

  ReservationModel copyWith({
    String? id,
    String? homeId,
    GuestModel? guest,
    DateTime? checkIn,
    DateTime? checkOut,
    ReservationStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      guest: guest ?? this.guest,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'homeId': homeId,
      'guestName': guest.name,
      'guestPhone': guest.phone,
      'guestEmail': guest.email,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'] as String,
      homeId: map['homeId'] as String,
      guest: GuestModel(
        name: map['guestName'] as String,
        phone: map['guestPhone'] as String?,
        email: map['guestEmail'] as String?,
      ),
      checkIn: DateTime.parse(map['checkIn'] as String),
      checkOut: DateTime.parse(map['checkOut'] as String),
      status: ReservationStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ReservationStatus.confirmed,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
