import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/data/repositories/farm_repository.dart';
import 'package:cakobean/domain/models/farm.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';

/// Provides the single [FarmRepository] instance app-wide.
final farmRepositoryProvider = Provider<FarmRepository>(
  (ref) => FarmRepository(),
);

/// Live list of the signed-in user's farms from Firestore. Empty while
/// signed out. Because Firestore's on-device cache is enabled, this resolves
/// instantly from cache and re-emits when the network syncs.
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
