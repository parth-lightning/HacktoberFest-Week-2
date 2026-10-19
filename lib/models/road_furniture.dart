import '../core/spatial/geo_coordinates.dart';

enum RoadFurnitureType {
  pickupPin,
  dropoffPin,
  recommendedPickupSpot,
  safetyBeacon,
  transitStation,
}

/// Representation of map overlays and POI markers, mirroring `com/ubercab/android/map/RoadFurniture`.
class RoadFurniture {
  final String id;
  final GeoCoordinates position;
  final RoadFurnitureType type;
  final String label;
  final String? subtitle;

  const RoadFurniture({
    required this.id,
    required this.position,
    required this.type,
    required this.label,
    this.subtitle,
  });
}
