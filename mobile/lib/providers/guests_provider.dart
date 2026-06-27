import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/models/guest_model.dart';
import 'repository_provider.dart';

final guestsProvider = FutureProvider<List<GuestModel>>((ref) async {
  final repo = ref.read(repositoryProvider);
  return repo.getGuests();
});
