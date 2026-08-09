import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cakobean/data/repositories/auth_repository.dart';
import 'package:cakobean/data/services/farm_service.dart';
import 'package:cakobean/domain/models/farm.dart';

/// Domain-facing repository over [FarmService]. Maps raw Firestore documents
/// to [FarmModel] and exposes the CRUD operations the UI needs. UI code never
/// touches Firestore directly.
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

  /// Creates a farm as the current user and returns it so the UI can show it
  /// immediately while the live stream catches up.
  Future<FarmModel> addFarm({
    required String address,
    required double sizeHectares,
    required int cacaoTrees,
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
      'cacaoTrees': cacaoTrees,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final ref = await _service.addFarm(data);
    return FarmModel(
      id: ref.id,
      address: trimmed,
      sizeHectares: sizeHectares,
      cacaoTrees: cacaoTrees,
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
      cacaoTrees: (data['cacaoTrees'] as num?)?.toInt() ?? 0,
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
      cacaoTrees: (data['cacaoTrees'] as num?)?.toInt() ?? 0,
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
      'cacaoTrees': farm.cacaoTrees,
      'latitude': farm.latitude,
      'longitude': farm.longitude,
    };
  }
}
