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
      _writeReservations(MockData.reservations());
    }
    if (!_box.containsKey(_kGuests)) {
      _writeGuests(MockData.guests);
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

  bool _hasGap(
    List<ReservationModel> existing,
    DateTime checkIn,
    DateTime checkOut,
    String? ignoreId,
  ) {
    final sorted = existing
        .where((r) => r.isActive && r.id != ignoreId)
        .toList()
      ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

    for (final r in sorted) {
      if (r.checkOutDate.isBefore(checkIn) || r.checkInDate.isAfter(checkOut)) {
        continue;
      }
    }

    final before = sorted.where((r) => r.checkOutDate.isBefore(checkIn)).toList()
      ..sort((a, b) => b.checkOutDate.compareTo(a.checkOutDate));
    if (before.isNotEmpty) {
      final prev = before.first;
      if (!_isSameDay(prev.checkOutDate, checkIn)) {
        return true;
      }
    }

    final after = sorted.where((r) => r.checkInDate.isAfter(checkOut)).toList()
      ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
    if (after.isNotEmpty) {
      final next = after.first;
      if (!_isSameDay(checkOut, next.checkInDate)) {
        return true;
      }
    }

    return false;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---------- Guests ----------
  Future<List<GuestModel>> getGuests() async => _readGuests();

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

  Future<HomeModel> updateHome(HomeModel home) async {
    final homes = _readHomes();
    final idx = homes.indexWhere((h) => h.id == home.id);
    if (idx == -1) throw Exception('HOME_NOT_FOUND');
    homes[idx] = home;
    _writeHomes(homes);
    return home;
  }

  Future<void> deleteHome(String id) async {
    final homes = _readHomes()..removeWhere((h) => h.id == id);
    _writeHomes(homes);
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

    final homeReservations =
        reservations.where((r) => r.homeId == homeId).toList();
    if (_hasGap(homeReservations, checkIn, checkOut, null)) {
      throw Exception('GAP_NOT_ALLOWED');
    }

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

    final homeReservations =
        reservations.where((r) => r.homeId == reservations[idx].homeId).toList();
    if (_hasGap(homeReservations, checkIn, checkOut, id)) {
      throw Exception('GAP_NOT_ALLOWED');
    }

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

  Future<void> deleteReservation(String id) async {
    final reservations = _readReservations()..removeWhere((r) => r.id == id);
    _writeReservations(reservations);
  }

  /// Returns all dates within [monthStart]..[monthEnd] mapped by homeId.
  /// Each date maps to the active [ReservationModel] that covers it, or null if void.
  Future<Map<String, Map<DateTime, ReservationModel?>>> getCalendarData({
    required DateTime monthStart,
    required DateTime monthEnd,
  }) async {
    final homes = _readHomes();
    final reservations = _readReservations();
    final dayCount = monthEnd.difference(monthStart).inDays + 1;

    final result = <String, Map<DateTime, ReservationModel?>>{};

    for (final home in homes) {
      final homeMap = <DateTime, ReservationModel?>{};
      for (var i = 0; i < dayCount; i++) {
        final day = monthStart.add(Duration(days: i));
        final covering = reservations.cast<ReservationModel?>().firstWhere(
          (r) =>
              r != null &&
              r.isActive &&
              r.homeId == home.id &&
              !r.checkInDate.isAfter(day) &&
              day.isBefore(r.checkOutDate),
          orElse: () => null,
        );
        homeMap[day] = covering;
      }
      result[home.id] = homeMap;
    }

    return result;
  }
}
