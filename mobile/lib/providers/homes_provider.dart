import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/models/home_model.dart';
import 'repository_provider.dart';

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
}
