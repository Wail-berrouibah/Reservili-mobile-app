import 'dart:convert';

import 'package:hive/hive.dart';

import '../shared/models/guest_model.dart';
import '../shared/models/home_model.dart';
import '../shared/models/reservation_model.dart';
import 'mock_data.dart';

class LocalRepository {
  static const _boxName = 'reservili';
  static const _kHomes = 'homes';
  static const _kGuests = 'guests';
  static const _kReservations = 'reservations';

  Box get _box => Hive.box(_boxName);

  LocalRepository() {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    if (!_box.containsKey(_kHomes)) {
      _writeHomes(MockData.homes);
      _writeGuests(MockData.guests);
      _writeReservations(MockData.reservations);
    }
  }

  // ---------- read / write helpers ----------
  List<HomeModel> _readHomes() {
    final raw = _box.get(_kHomes) as String?;
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => HomeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<GuestModel> _readGuests() {
    final raw = _box.get(_kGuests) as String?;
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => GuestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<ReservationModel> _readReservations() {
    final raw = _box.get(_kReservations) as String?;
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _writeHomes(List<HomeModel> homes) =>
      _box.put(_kHomes, jsonEncode(homes.map((e) => e.toJson()).toList()));
  void _writeGuests(List<GuestModel> guests) =>
      _box.put(_kGuests, jsonEncode(guests.map((e) => e.toJson()).toList()));
  void _writeReservations(List<ReservationModel> items) =>
      _box.put(_kReservations,
          jsonEncode(items.map((e) => e.toJson()).toList()));

  bool _overlaps(
    ReservationModel r,
    DateTime checkIn,
    DateTime checkOut,
  ) =>
      r.status != ReservationStatus.cancelled &&
      r.checkInDate.isBefore(checkOut) &&
      r.checkOutDate.isAfter(checkIn);

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---------- Homes ----------
  Future<List<HomeModel>> getHomes() async => _readHomes();

  Future<List<HomeModel>> getAvailableHomes(
      DateTime checkIn, DateTime checkOut) async {
    final reservations = _readReservations();
    return _readHomes().where((h) {
      if (h.status != HomeStatus.available) return false;
      final taken = reservations
          .any((r) => r.homeId == h.id && _overlaps(r, checkIn, checkOut));
      return !taken;
    }).toList();
  }

  Future<HomeModel> addHome(HomeModel home) async {
    final homes = _readHomes()..add(home);
    _writeHomes(homes);
    return home;
  }

  // ---------- Reservations ----------
  Future<List<ReservationModel>> getReservations() async =>
      _readReservations();

  Future<ReservationModel> createReservation({
    required String homeId,
    required String guestName,
    required String guestPhone,
    String? guestEmail,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestsCount,
    String? notes,
  }) async {
    final reservations = _readReservations();
    final taken = reservations
        .any((r) => r.homeId == homeId && _overlaps(r, checkIn, checkOut));
    if (taken) throw Exception('DATES_UNAVAILABLE');

    final guest = GuestModel(
      id: _newId(),
      fullName: guestName,
      phone: guestPhone,
      email: guestEmail,
    );
    _writeGuests(_readGuests()..add(guest));

    final now = DateTime.now();
    final reservation = ReservationModel(
      id: _newId(),
      homeId: homeId,
      guestId: guest.id,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      guestsCount: guestsCount,
      status: ReservationStatus.pending,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    reservations.add(reservation);
    _writeReservations(reservations);
    return reservation;
  }

  Future<ReservationModel> setStatus(
      String id, ReservationStatus status) async {
    final reservations = _readReservations();
    final idx = reservations.indexWhere((r) => r.id == id);
    if (idx == -1) throw Exception('RESERVATION_NOT_FOUND');
    final r = reservations[idx];
    reservations[idx] = ReservationModel(
      id: r.id,
      homeId: r.homeId,
      guestId: r.guestId,
      checkInDate: r.checkInDate,
      checkOutDate: r.checkOutDate,
      guestsCount: r.guestsCount,
      status: status,
      notes: r.notes,
      createdAt: r.createdAt,
      updatedAt: DateTime.now(),
    );
    _writeReservations(reservations);
    return reservations[idx];
  }

  Future<ReservationModel> reschedule(
      String id, DateTime checkIn, DateTime checkOut) async {
    final reservations = _readReservations();
    final idx = reservations.indexWhere((r) => r.id == id);
    if (idx == -1) throw Exception('RESERVATION_NOT_FOUND');

    final taken = reservations.any((r) =>
        r.id != id &&
        r.homeId == reservations[idx].homeId &&
        _overlaps(r, checkIn, checkOut));
    if (taken) throw Exception('DATES_UNAVAILABLE');

    final r = reservations[idx];
    reservations[idx] = ReservationModel(
      id: r.id,
      homeId: r.homeId,
      guestId: r.guestId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      guestsCount: r.guestsCount,
      status: r.status,
      notes: r.notes,
      createdAt: r.createdAt,
      updatedAt: DateTime.now(),
    );
    _writeReservations(reservations);
    return reservations[idx];
  }
}
