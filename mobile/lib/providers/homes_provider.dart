import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/models/home_model.dart';
import 'repository_provider.dart';
import 'reservations_provider.dart';

/// Loads and holds the list of homes.
final homesProvider =
    AsyncNotifierProvider<HomesNotifier, List<HomeModel>>(HomesNotifier.new);

class HomesNotifier extends AsyncNotifier<List<HomeModel>> {
  @override
  Future<List<HomeModel>> build() async {
    final repo = ref.read(repositoryProvider);
    return repo.getHomes();
  }

  Future<void> addHome(HomeModel home) async {
    final repo = ref.read(repositoryProvider);
    await repo.addHome(home);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateHome(HomeModel home) async {
    final repo = ref.read(repositoryProvider);
    await repo.updateHome(home);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteHome(String id) async {
    final repo = ref.read(repositoryProvider);
    await repo.deleteHome(id);
    ref.invalidateSelf();
    ref.invalidate(reservationsProvider);
    await future;
  }
}
