import 'package:flutter/foundation.dart';
import '../shared/models/home_model.dart';
import '../data/mock_data.dart';

class HomesProvider extends ChangeNotifier {
  final List<HomeModel> _homes = [];

  List<HomeModel> get homes => List.unmodifiable(_homes);

  int get totalHomes => _homes.length;
  int get availableHomes => _homes.where((h) => h.isAvailable).length;

  void loadMockData() {
    _homes.addAll(MockData.sampleHomes);
    notifyListeners();
  }

  List<HomeModel> searchHomes(String query) {
    final q = query.toLowerCase();
    return _homes.where((h) =>
      h.name.toLowerCase().contains(q) ||
      h.address.toLowerCase().contains(q)
    ).toList();
  }

  List<HomeModel> getAvailableHomes() {
    return _homes.where((h) => h.isAvailable).toList();
  }

  HomeModel? getHomeById(String id) {
    try {
      return _homes.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  void addHome(HomeModel home) {
    _homes.add(home);
    notifyListeners();
  }

  void updateHome(HomeModel home) {
    final index = _homes.indexWhere((h) => h.id == home.id);
    if (index != -1) {
      _homes[index] = home;
      notifyListeners();
    }
  }

  void toggleAvailability(String id) {
    final index = _homes.indexWhere((h) => h.id == id);
    if (index != -1) {
      final home = _homes[index];
      _homes[index] = home.copyWith(isAvailable: !home.isAvailable);
      notifyListeners();
    }
  }

  void deleteHome(String id) {
    _homes.removeWhere((h) => h.id == id);
    notifyListeners();
  }
}
