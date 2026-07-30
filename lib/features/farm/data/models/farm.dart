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

const mockFarms = <FarmModel>[
  FarmModel(
    id: '1',
    address: 'Sitio Malinao, Brgy. San Isidro, Davao del Sur',
    sizeHectares: 13.2,
    cacaoTrees: 25,
    latitude: 6.7642,
    longitude: 125.3572,
  ),
  FarmModel(
    id: '2',
    address: 'Purok 4, Brgy. Malabog, Davao City',
    sizeHectares: 5.8,
    cacaoTrees: 5,
    latitude: 7.2119,
    longitude: 125.5316,
  ),
  FarmModel(
    id: '3',
    address: 'Km 14, Brgy. Tamayong, Calinan',
    sizeHectares: 22.1,
    cacaoTrees: 21,
    latitude: 7.1725,
    longitude: 125.3908,
  ),
  FarmModel(
    id: '4',
    address: 'Sitio Kahoy, Brgy. Baguio, Davao City',
    sizeHectares: 4.5,
    cacaoTrees: 15,
    latitude: 7.1907,
    longitude: 125.4553,
  ),
];
