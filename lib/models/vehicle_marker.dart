import '../core/spatial/geo_coordinates.dart';
import '../core/spatial/h3_index.dart';

/// Representation of a nearby driver/vehicle on the vector map,
/// mirroring `com/ubercab/android/map/UserLocation` and 3D vehicle orientation.
class VehicleMarker {
  final String id;
  final GeoCoordinates position;
  final double bearing; // In degrees (0..360)
  final String modelName;
  final String licensePlate;
  final H3Index h3Cell;

  const VehicleMarker({
    required this.id,
    required this.position,
    required this.bearing,
    required this.modelName,
    required this.licensePlate,
    required this.h3Cell,
  });

  /// Factory creating vehicle with calculated H3 index at standard Uber resolution 8
  factory VehicleMarker.create({
    required String id,
    required GeoCoordinates position,
    required double bearing,
    required String modelName,
    required String licensePlate,
  }) {
    final h3 = H3Index.fromGeo(position, 8);
    return VehicleMarker(
      id: id,
      position: position,
      bearing: bearing,
      modelName: modelName,
      licensePlate: licensePlate,
      h3Cell: h3,
    );
  }

  /// Interpolates position towards destination for smooth vehicle movement animation
  VehicleMarker interpolate(GeoCoordinates target, double progress) {
    final newLat = position.latitude + (target.latitude - position.latitude) * progress;
    final newLng = position.longitude + (target.longitude - position.longitude) * progress;
    final newBearing = position.bearingTo(target);
    final newPos = GeoCoordinates(newLat, newLng);

    return VehicleMarker(
      id: id,
      position: newPos,
      bearing: newBearing,
      modelName: modelName,
      licensePlate: licensePlate,
      h3Cell: H3Index.fromGeo(newPos, 8),
    );
  }
}
