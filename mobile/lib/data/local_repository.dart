import '../shared/models/home_model.dart';
import '../shared/models/reservation_model.dart';

class LocalRepository {
  final List<HomeModel> _homes = [];
  final List<ReservationModel> _reservations = [];

  List<HomeModel> getHomes() => List.unmodifiable(_homes);
  List<ReservationModel> getReservations() => List.unmodifiable(_reservations);

  HomeModel? getHomeById(String id) {
    try {
      return _homes.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  ReservationModel? getReservationById(String id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void addHome(HomeModel home) => _homes.add(home);
  void updateHome(HomeModel home) {
    final i = _homes.indexWhere((h) => h.id == home.id);
    if (i != -1) _homes[i] = home;
  }
  void deleteHome(String id) => _homes.removeWhere((h) => h.id == id);

  void addReservation(ReservationModel r) => _reservations.add(r);
  void updateReservation(ReservationModel r) {
    final i = _reservations.indexWhere((x) => x.id == r.id);
    if (i != -1) _reservations[i] = r;
  }
  void deleteReservation(String id) => _reservations.removeWhere((r) => r.id == id);
}
