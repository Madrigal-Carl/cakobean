/// Lifecycle/health status of a cacao tree. Stored in the database as the
/// enum name and mapped back when reading. The UI maps each status to an icon
/// and theme color via `lib/ui/features/farm/widgets/tree_status.dart`.
enum TreeStatus {
  /// Growing normally, no issues.
  healthy,

  /// Currently in flower.
  flowering,

  /// Bearing cacao pods.
  fruiting,

  /// Pests, disease, or other stress — needs attention.
  needsCare,

  /// Seasonal rest / low activity.
  dormant,
}

/// A single cacao tree inside a farm. Trees live in a subcollection
/// (`farms/{farmId}/trees`) so a farm can have any number of them and the
/// count is derived from the actual trees rather than a stored number.
class CacaoTree {
  final String id;
  final String farmId;
  final String name;
  final String? variety;
  final DateTime? plantedOn;
  final TreeStatus status;
  final DateTime createdAt;

  const CacaoTree({
    required this.id,
    required this.farmId,
    required this.name,
    this.variety,
    this.plantedOn,
    this.status = TreeStatus.healthy,
    required this.createdAt,
  });

  CacaoTree copyWith({
    String? name,
    String? variety,
    DateTime? plantedOn,
    TreeStatus? status,
  }) {
    return CacaoTree(
      id: id,
      farmId: farmId,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      plantedOn: plantedOn ?? this.plantedOn,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
