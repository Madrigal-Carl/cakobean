import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:cakobean/data/services/supabase_live.dart';

/// Low-level wrapper around Supabase (Postgres + Realtime) for the Farm
/// feature. Deals exclusively in raw rows/maps — no domain model knowledge.
/// Mapping happens in [FarmRepository] (data layer).
///
/// Schema (snake_case columns):
/// - `farms` — one row per farm, referencing its owner by `owner_id`.
/// - `trees` — one row per cacao tree, referencing `farm_id`.
/// Farms are scoped to their owner via a single-column filter (`owner_id`),
/// so each user only ever sees their own farms.
class FarmService {
  FarmService({sb.SupabaseClient? client})
      : _client = client ?? sb.Supabase.instance.client;

  final sb.SupabaseClient _client;

  /// Live list of farms owned by [ownerId].
  Stream<List<Map<String, dynamic>>> watchFarms(String ownerId) {
    return _client
        .from('farms')
        .stream(primaryKey: ['id'])
        .eq('owner_id', ownerId);
  }

  /// Live single farm row. Emits null when the farm doesn't exist.
  Stream<Map<String, dynamic>?> watchFarm(String farmId) {
    return supabaseLiveStream(
      table: 'farms',
      filter: sb.PostgresChangeFilter(
        column: 'id',
        type: sb.PostgresChangeFilterType.eq,
        value: farmId,
      ),
      fetch: () => _client
          .from('farms')
          .select()
          .eq('id', farmId)
          .maybeSingle(),
    );
  }

  /// Live list of a farm's cacao trees, oldest first.
  Stream<List<Map<String, dynamic>>> watchTrees(String farmId) {
    return _client
        .from('trees')
        .stream(primaryKey: ['id'])
        .eq('farm_id', farmId)
        .order('created_at', ascending: true);
  }

  /// Adds a cacao tree to [farmId] and returns its id.
  Future<String> addTree(String farmId, Map<String, dynamic> data) async {
    final row = await _client
        .from('trees')
        .insert({...data, 'farm_id': farmId})
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> updateTree(String treeId, Map<String, dynamic> data) {
    return _client.from('trees').update(data).eq('id', treeId);
  }

  Future<void> deleteTree(String treeId) {
    return _client.from('trees').delete().eq('id', treeId);
  }

  /// Adds a farm and returns its id.
  Future<String> addFarm(Map<String, dynamic> data) async {
    final row = await _client
        .from('farms')
        .insert(data)
        .select('id')
        .single();
    return row['id'] as String;
  }

  /// Updates a farm's editable columns.
  Future<void> updateFarm(String farmId, Map<String, dynamic> data) {
    return _client.from('farms').update(data).eq('id', farmId);
  }

  Future<void> deleteFarm(String farmId) {
    return _client.from('farms').delete().eq('id', farmId);
  }
}
