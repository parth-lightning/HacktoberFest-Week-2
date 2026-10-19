import 'dart:async';
import 'dart:math' as math;
import '../core/spatial/geo_coordinates.dart';
import '../core/spatial/h3_index.dart';

/// Simulates location tracking and H3 spatial cell updates.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Default coordinate: San Francisco Financial District / Market St
  GeoCoordinates _currentLocation = const GeoCoordinates(37.7897, -122.4011);
  final StreamController<GeoCoordinates> _locationController =
      StreamController<GeoCoordinates>.broadcast();

  GeoCoordinates get currentLocation => _currentLocation;
  Stream<GeoCoordinates> get locationStream => _locationController.stream;

  H3Index get currentH3Cell => H3Index.fromGeo(_currentLocation, 8);

  void updateLocation(GeoCoordinates newLocation) {
    _currentLocation = newLocation;
    _locationController.add(newLocation);
  }

  /// Generates synthetic nearby vehicles clustered in the current H3 cell neighborhood
  List<GeoCoordinates> generateNearbyVehiclePositions(int count) {
    final List<GeoCoordinates> positions = [];
    final random = math.Random(42);
    for (int i = 0; i < count; i++) {
      final double dLat = (random.nextDouble() - 0.5) * 0.015;
      final double dLng = (random.nextDouble() - 0.5) * 0.015;
      positions.add(GeoCoordinates(
        _currentLocation.latitude + dLat,
        _currentLocation.longitude + dLng,
      ));
    }
    return positions;
  }
}
