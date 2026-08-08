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
    address: 'Brgy. Bangbangalon, Boac, Marinduque',
    sizeHectares: 13.2,
    cacaoTrees: 25,
    latitude: 13.4468,
    longitude: 121.8403,
  ),
  FarmModel(
    id: '2',
    address: 'Brgy. Bahi, Gasan, Marinduque',
    sizeHectares: 5.8,
    cacaoTrees: 5,
    latitude: 13.3235,
    longitude: 121.8465,
  ),
  FarmModel(
    id: '3',
    address: 'Brgy. Bagtingon, Buenavista, Marinduque',
    sizeHectares: 22.1,
    cacaoTrees: 21,
    latitude: 13.2558,
    longitude: 121.9396,
  ),
  FarmModel(
    id: '4',
    address: 'Brgy. Makulapnit, Santa Cruz, Marinduque',
    sizeHectares: 4.5,
    cacaoTrees: 15,
    latitude: 13.4776,
    longitude: 122.0355,
  ),
];
