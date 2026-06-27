import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_repository.dart';

final repositoryProvider =
    Provider<LocalRepository>((ref) => LocalRepository());
