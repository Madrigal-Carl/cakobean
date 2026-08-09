import 'package:cakobean/data/repositories/auth_repository.dart';
import 'package:cakobean/data/services/farm_service.dart';
import 'package:cakobean/domain/models/cacao_tree.dart';
import 'package:cakobean/domain/models/farm.dart';

/// Domain-facing repository over [FarmService]. Maps raw Supabase rows to
/// [FarmModel]/[CacaoTree] and exposes the CRUD operations the UI needs.
/// UI code never touches Supabase directly.
class FarmRepository {
  FarmRepository({FarmService? service, AuthRepository? auth})
      : _service = service ?? FarmService(),
        _auth = auth ?? AuthRepository();

  final FarmService _service;
  final AuthRepository _auth;

  /// Live list of the current user's farms.
  Stream<List<FarmModel>> watchFarms() {
    return _service
        .watchFarms(ownerId)
        .map((rows) => rows.map(_farmFromRow).toList());
  }

  /// Live list of ALL farms. `panuluyan` may read every farm (read-only);
  /// every other role is limited to their own by the database policy.
  Stream<List<FarmModel>> watchAllFarms() {
    return _service
        .watchAllFarms()
        .map((rows) => rows.map(_farmFromRow).toList());
  }

  /// Live single farm. Null when the row doesn't exist (e.g. deleted).
  Stream<FarmModel?> watchFarm(String farmId) {
    return _service.watchFarm(farmId).map(
          (row) => row == null ? null : _farmFromRow(row),
        );
  }

  /// Live list of a farm's cacao trees.
  Stream<List<CacaoTree>> watchTrees(String farmId) {
    return _service
        .watchTrees(farmId)
        .map((rows) => rows.map(_treeFromRow).toList());
  }

  /// Creates a farm as the current user and returns it so the UI can show it
  /// immediately while the live stream catches up.
  Future<FarmModel> addFarm({
    required String address,
    required double sizeHectares,
    double? latitude,
    double? longitude,
  }) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Farm address must not be empty.');
    }
    final data = <String, dynamic>{
      'owner_id': ownerId,
      'address': trimmed,
      'size_hectares': sizeHectares,
      'latitude': latitude,
      'longitude': longitude,
    };
    final id = await _service.addFarm(data);
    return FarmModel(
      id: id,
      address: trimmed,
      sizeHectares: sizeHectares,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Overwrites the editable fields of an existing farm.
  Future<void> updateFarm(FarmModel farm) {
    return _service.updateFarm(farm.id, _farmToMap(farm, ownerId: ownerId));
  }

  Future<void> deleteFarm(String farmId) {
    return _service.deleteFarm(farmId);
  }

  /// Adds a cacao tree to [farmId]. Auto-names it when [name] is blank so a
  /// tree is always identifiable even if the user skips the name field.
  Future<CacaoTree> addTree({
    required String farmId,
    required String name,
    String? variety,
    DateTime? plantedOn,
    TreeStatus status = TreeStatus.healthy,
  }) async {
    final finalName = name.trim().isEmpty ? 'Cacao tree' : name.trim();
    final id = await _service.addTree(
      farmId,
      _treeToMap(
        CacaoTree(
          id: '',
          farmId: farmId,
          name: finalName,
          variety: variety,
          plantedOn: plantedOn,
          status: status,
          createdAt: DateTime.now(),
        ),
      ),
    );
    return CacaoTree(
      id: id,
      farmId: farmId,
      name: finalName,
      variety: variety,
      plantedOn: plantedOn,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  Future<void> updateTree(CacaoTree tree) {
    return _service.updateTree(tree.id, _treeToMap(tree));
  }

  Future<void> deleteTree(String farmId, String treeId) {
    return _service.deleteTree(treeId);
  }

  /// Identity of the person who owns the farm. Falls back to a guest id when
  /// not signed in, but the app forces login anyway.
  String get ownerId => _auth.currentUser?.uid ?? 'guest';

  // ── Mapping ────────────────────────────────────────────────────────────

  static FarmModel _farmFromRow(Map<String, dynamic> row) {
    return FarmModel(
      id: row['id'] as String? ?? '',
      ownerId: row['owner_id'] as String? ?? '',
      address: row['address'] as String? ?? '',
      sizeHectares: (row['size_hectares'] as num?)?.toDouble() ?? 0,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> _farmToMap(
    FarmModel farm, {
    required String ownerId,
  }) {
    return {
      'owner_id': ownerId,
      'address': farm.address,
      'size_hectares': farm.sizeHectares,
      'latitude': farm.latitude,
      'longitude': farm.longitude,
    };
  }

  static CacaoTree _treeFromRow(Map<String, dynamic> row) {
    return CacaoTree(
      id: row['id'] as String? ?? '',
      farmId: row['farm_id'] as String? ?? '',
      name: row['name'] as String? ?? 'Cacao tree',
      variety: row['variety'] as String?,
      plantedOn: _parseDate(row['planted_on']),
      status: _treeStatus(row['status']),
      createdAt: _parseDate(row['created_at']) ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> _treeToMap(CacaoTree tree) {
    return {
      'farm_id': tree.farmId,
      'name': tree.name,
      'variety': tree.variety,
      'planted_on': tree.plantedOn?.toIso8601String(),
      'status': tree.status.name,
    };
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value.toLocal();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

  static TreeStatus _treeStatus(Object? value) {
    if (value is! String) return TreeStatus.healthy;
    return TreeStatus.values.asNameMap()[value] ?? TreeStatus.healthy;
  }
}
