import 'package:cloud_firestore/cloud_firestore.dart';

/// Low-level wrapper around [FirebaseFirestore] for the Farm feature.
/// Deals exclusively in raw Firestore documents/maps — it has no knowledge
/// of the domain models. Mapping happens in [FarmRepository] (data layer).
///
/// Schema:
/// - `farms` — one doc per farm, referencing its owner by `ownerId`.
/// Farms are scoped to their owner via a single-field query (`ownerId`),
/// so each user only ever sees their own farms.
class FarmService {
  FarmService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _farms =>
      _db.collection('farms');

  /// Live list of farms owned by [ownerId].
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchFarms(
    String ownerId,
  ) {
    return _farms
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((query) => query.docs);
  }

  /// Live single farm document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchFarm(String farmId) {
    return _farms.doc(farmId).snapshots();
  }

  /// Adds a farm to the `farms` collection. Returns the created document
  /// reference so the caller can build a [FarmModel] with the real id.
  Future<DocumentReference<Map<String, dynamic>>> addFarm(
    Map<String, dynamic> data,
  ) {
    return _farms.add(data);
  }

  /// Updates a farm. Merge keeps fields the form doesn't edit (like
  /// `createdAt`) intact.
  Future<void> updateFarm(String farmId, Map<String, dynamic> data) {
    return _farms.doc(farmId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteFarm(String farmId) {
    return _farms.doc(farmId).delete();
  }
}
