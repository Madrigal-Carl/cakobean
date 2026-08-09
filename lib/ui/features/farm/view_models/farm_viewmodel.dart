import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/data/repositories/farm_repository.dart';
import 'package:cakobean/domain/models/cacao_tree.dart';
import 'package:cakobean/domain/models/farm.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';

/// Provides the single [FarmRepository] instance app-wide.
final farmRepositoryProvider = Provider<FarmRepository>(
  (ref) => FarmRepository(),
);

/// Live list of the signed-in user's farms from Supabase. Empty while
/// signed out. Realtime keeps the list in sync across devices.
final farmsProvider = StreamProvider<List<FarmModel>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(const <FarmModel>[]);
  return ref.watch(farmRepositoryProvider).watchFarms();
});

/// Live single farm, used by the detail page. Null when the document doesn't
/// exist (e.g. the farm was deleted).
final farmProvider = StreamProvider.family<FarmModel?, String>(
  (ref, farmId) => ref.watch(farmRepositoryProvider).watchFarm(farmId),
);

/// Live list of a farm's cacao trees, used by the detail page (and to show
/// the derived tree count on the farm cards).
final farmTreesProvider = StreamProvider.family<List<CacaoTree>, String>(
  (ref, farmId) => ref.watch(farmRepositoryProvider).watchTrees(farmId),
);
