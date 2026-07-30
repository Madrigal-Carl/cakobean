/// ---- Farm model ----
class FarmModel {
  final String name;
  final String address;
  final double sizeHectares;
  final int cacaoTrees;

  const FarmModel({
    required this.name,
    required this.address,
    required this.sizeHectares,
    required this.cacaoTrees,
  });
}

/// Temporary mock data — swap for a repository/API call once the backend
/// is wired up.
const mockFarms = <FarmModel>[
  FarmModel(
    name: 'Bukid ni Mang Tomas',
    address: 'Sitio Malinao, Brgy. San Isidro, Davao del Sur',
    sizeHectares: 3.2,
    cacaoTrees: 480,
  ),
  FarmModel(
    name: 'Green Hills Cacao Farm',
    address: 'Purok 4, Brgy. Malabog, Davao City',
    sizeHectares: 5.8,
    cacaoTrees: 910,
  ),
  FarmModel(
    name: 'Rio Verde Plantation',
    address: 'Km 14, Brgy. Tamayong, Calinan',
    sizeHectares: 2.1,
    cacaoTrees: 310,
  ),
  FarmModel(
    name: 'Sitio Kahoy Farm',
    address: 'Sitio Kahoy, Brgy. Baguio, Davao City',
    sizeHectares: 4.5,
    cacaoTrees: 675,
  ),
];
