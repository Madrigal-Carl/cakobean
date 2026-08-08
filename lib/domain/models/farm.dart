class FarmModel {
  final String id;
  final String address;
  final double sizeHectares;
  final int cacaoTrees;
  final double? latitude;
  final double? longitude;

  const FarmModel({
    required this.id,
    required this.address,
    required this.sizeHectares,
    required this.cacaoTrees,
    this.latitude,
    this.longitude,
  });
}
