import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/data/repositories/farm_repository.dart';
import 'package:cakobean/domain/models/cacao_tree.dart';
import 'package:cakobean/domain/models/farm.dart';
import 'package:cakobean/domain/models/hub_user.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';

/// Provides the single [FarmRepository] instance app-wide.
final farmRepositoryProvider = Provider<FarmRepository>(
  (ref) => FarmRepository(),
);

/// Live role of the signed-in user from their `users` row. Null while signed
/// out or the profile hasn't been written yet. Drives whether the farm
/// feature runs in read-only monitoring mode (`panuluyan`) or personal
/// management mode.
final farmRoleProvider = Provider<HubUser?>(
  (ref) => ref.watch(hubCurrentUserProvider).value,
);

/// The signed-in user's id, used to tell whether a farm belongs to them.
final farmCurrentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
);

/// True when the signed-in user's role grants read-only access to every farm.
bool isPanuluyanRole(HubUser? user) => user?.role == hubPanuluyanRole;

/// Live list of farms. `panuluyan` sees every farm (read-only monitoring);
/// everyone else sees only their own. Empty while signed out. Realtime keeps
/// the list in sync across devices.
final farmsProvider = StreamProvider<List<FarmModel>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(const <FarmModel>[]);
  final repo = ref.watch(farmRepositoryProvider);
  return isPanuluyanRole(ref.watch(farmRoleProvider))
      ? repo.watchAllFarms()
      : repo.watchFarms();
});

/// True when the signed-in user can manage (edit/delete) a farm — i.e. they
/// own it. Everyone else, including a `panuluyan` viewing another farmer's
/// farm, sees it read-only.
final farmCanManageProvider = Provider.family<bool, String>(
  (ref, farmId) {
    final farm = ref.watch(farmProvider(farmId)).value;
    if (farm == null) return false;
    return ref.watch(farmCurrentUserIdProvider) != null &&
        farm.ownerId == ref.watch(farmCurrentUserIdProvider);
  },
);

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
