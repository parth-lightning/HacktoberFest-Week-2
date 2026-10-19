enum RideTier {
  uberX,
  comfort,
  black,
  uberXL,
  green,
}

class RideCategory {
  final String id;
  final String name;
  final String tagline;
  final double basePrice;
  final double perKmRate;
  final int capacity;
  final int estimatedEtaMinutes;
  final RideTier tier;
  final String iconAsset;

  const RideCategory({
    required this.id,
    required this.name,
    required this.tagline,
    required this.basePrice,
    required this.perKmRate,
    required this.capacity,
    required this.estimatedEtaMinutes,
    required this.tier,
    required this.iconAsset,
  });

  double calculateFare(double distanceKm, double surgeMultiplier) {
    final fare = (basePrice + (distanceKm * perKmRate)) * surgeMultiplier;
    return (fare * 100).roundToDouble() / 100.0;
  }
}

final List<RideCategory> kDefaultRideCategories = [
  const RideCategory(
    id: 'uber_x',
    name: 'UberX',
    tagline: 'Affordable, everyday rides',
    basePrice: 5.50,
    perKmRate: 1.45,
    capacity: 4,
    estimatedEtaMinutes: 3,
    tier: RideTier.uberX,
    iconAsset: 'car_sedan',
  ),
  const RideCategory(
    id: 'uber_comfort',
    name: 'Comfort',
    tagline: 'Newer cars with extra legroom',
    basePrice: 8.00,
    perKmRate: 1.85,
    capacity: 4,
    estimatedEtaMinutes: 5,
    tier: RideTier.comfort,
    iconAsset: 'car_comfort',
  ),
  const RideCategory(
    id: 'uber_black',
    name: 'Uber Black',
    tagline: 'Premium rides with professional drivers',
    basePrice: 15.00,
    perKmRate: 3.20,
    capacity: 4,
    estimatedEtaMinutes: 7,
    tier: RideTier.black,
    iconAsset: 'car_black',
  ),
  const RideCategory(
    id: 'uber_xl',
    name: 'UberXL',
    tagline: 'Affordable rides for groups up to 6',
    basePrice: 10.00,
    perKmRate: 2.30,
    capacity: 6,
    estimatedEtaMinutes: 6,
    tier: RideTier.uberXL,
    iconAsset: 'car_suv',
  ),
  const RideCategory(
    id: 'uber_green',
    name: 'Uber Green',
    tagline: '100% electric & hybrid vehicles',
    basePrice: 6.00,
    perKmRate: 1.50,
    capacity: 4,
    estimatedEtaMinutes: 4,
    tier: RideTier.green,
    iconAsset: 'car_electric',
  ),
];
