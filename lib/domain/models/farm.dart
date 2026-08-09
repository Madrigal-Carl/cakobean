class FarmModel {
  final String id;
  final String ownerId;
  final String address;
  final double sizeHectares;
  final double? latitude;
  final double? longitude;

  const FarmModel({
    required this.id,
    this.ownerId = '',
    required this.address,
    required this.sizeHectares,
    this.latitude,
    this.longitude,
  });
}
