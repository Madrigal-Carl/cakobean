import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cakobean/data/repositories/auth_repository.dart';
import 'package:cakobean/data/services/farm_service.dart';
import 'package:cakobean/domain/models/cacao_tree.dart';
import 'package:cakobean/domain/models/farm.dart';

/// Domain-facing repository over [FarmService]. Maps raw Firestore documents
/// to [FarmModel]/[CacaoTree] and exposes the CRUD operations the UI needs.
/// UI code never touches Firestore directly.
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
        .map((docs) => docs.map(_farmFromFirestore).toList());
  }

  /// Live single farm. Null when the document doesn't exist (e.g. deleted).
  Stream<FarmModel?> watchFarm(String farmId) {
    return _service.watchFarm(farmId).map(_farmFromSnapshot);
  }

  /// Live list of a farm's cacao trees.
  Stream<List<CacaoTree>> watchTrees(String farmId) {
    return _service
        .watchTrees(farmId)
        .map((docs) => docs.map(_treeFromFirestore).toList());
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
      'ownerId': ownerId,
      'address': trimmed,
      'sizeHectares': sizeHectares,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final ref = await _service.addFarm(data);
    return FarmModel(
      id: ref.id,
      address: trimmed,
      sizeHectares: sizeHectares,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Overwrites the editable fields of an existing farm. Merge keeps fields
  /// the form doesn't edit (like `createdAt`) intact.
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
    final ref = await _service.addTree(
      farmId,
      {
        ..._treeToMap(
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
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
    return CacaoTree(
      id: ref.id,
      farmId: farmId,
      name: finalName,
      variety: variety,
      plantedOn: plantedOn,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  Future<void> updateTree(CacaoTree tree) {
    return _service.updateTree(tree.farmId, tree.id, _treeToMap(tree));
  }

  Future<void> deleteTree(String farmId, String treeId) {
    return _service.deleteTree(farmId, treeId);
  }

  /// Identity of the person who owns the farm. Falls back to a guest id when
  /// not signed in, but the app forces login anyway.
  String get ownerId => _auth.currentUser?.uid ?? 'guest';

  // ── Mapping ────────────────────────────────────────────────────────────

  static FarmModel? _farmFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    if (!doc.exists) return null;
    final data = doc.data() ?? const <String, dynamic>{};
    return FarmModel(
      id: doc.id,
      address: data['address'] as String? ?? '',
      sizeHectares: (data['sizeHectares'] as num?)?.toDouble() ?? 0,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  static FarmModel _farmFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return FarmModel(
      id: doc.id,
      address: data['address'] as String? ?? '',
      sizeHectares: (data['sizeHectares'] as num?)?.toDouble() ?? 0,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> _farmToMap(
    FarmModel farm, {
    required String ownerId,
  }) {
    return {
      'ownerId': ownerId,
      'address': farm.address,
      'sizeHectares': farm.sizeHectares,
      'latitude': farm.latitude,
      'longitude': farm.longitude,
    };
  }

  static CacaoTree _treeFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CacaoTree(
      id: doc.id,
      farmId: data['farmId'] as String? ?? '',
      name: data['name'] as String? ?? 'Cacao tree',
      variety: data['variety'] as String?,
      plantedOn: _parseDate(data['plantedOn']),
      status: _treeStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> _treeToMap(CacaoTree tree) {
    return {
      'farmId': tree.farmId,
      'name': tree.name,
      'variety': tree.variety,
      'plantedOn': tree.plantedOn?.toIso8601String(),
      'status': tree.status.name,
    };
  }

  static DateTime? _parseDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  static TreeStatus _treeStatus(Object? value) {
    if (value is! String) return TreeStatus.healthy;
    return TreeStatus.values.asNameMap()[value] ?? TreeStatus.healthy;
  }
}
