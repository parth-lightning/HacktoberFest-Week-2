import 'dart:math' as math;

/// Core geographic coordinates representation, mirroring `com/ubercab/android/map/LatLng`.
class GeoCoordinates {
  final double latitude;
  final double longitude;

  const GeoCoordinates(this.latitude, this.longitude);

  /// Great-circle distance between two coordinates in meters (Haversine formula).
  double distanceTo(GeoCoordinates other) {
    const double earthRadiusMeters = 6371000.0;
    final double dLat = _degToRad(other.latitude - latitude);
    final double dLon = _degToRad(other.longitude - longitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(latitude)) *
            math.cos(_degToRad(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Initial bearing from this point to another point in degrees (0..360).
  double bearingTo(GeoCoordinates other) {
    final double lat1 = _degToRad(latitude);
    final double lat2 = _degToRad(other.latitude);
    final double dLon = _degToRad(other.longitude - longitude);

    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final double brng = math.atan2(y, x);
    return (_radToDeg(brng) + 360.0) % 360.0;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoCoordinates &&
          runtimeType == other.runtimeType &&
          (latitude - other.latitude).abs() < 1e-7 &&
          (longitude - other.longitude).abs() < 1e-7;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoCoordinates($latitude, $longitude)';
}

/// Geographic bounding box, mirroring `com/ubercab/android/map/LatLngBounds`.
class GeoBounds {
  final GeoCoordinates southwest;
  final GeoCoordinates northeast;

  const GeoBounds({
    required this.southwest,
    required this.northeast,
  });

  bool contains(GeoCoordinates point) {
    return point.latitude >= southwest.latitude &&
        point.latitude <= northeast.latitude &&
        point.longitude >= southwest.longitude &&
        point.longitude <= northeast.longitude;
  }

  GeoCoordinates get center => GeoCoordinates(
        (southwest.latitude + northeast.latitude) / 2.0,
        (southwest.longitude + northeast.longitude) / 2.0,
      );
}
