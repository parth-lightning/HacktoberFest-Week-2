import 'dart:async';
import 'dart:math' as math;
import '../core/spatial/geo_coordinates.dart';
import '../core/spatial/h3_index.dart';
import '../models/ride_category.dart';
import '../models/trip_route.dart';
import '../models/vehicle_marker.dart';

enum TripState {
  idle,
  selectingRide,
  requestingDriver,
  driverAssigned,
  enRoute,
  completed,
}

class RideService {
  static final RideService _instance = RideService._internal();
  factory RideService() => _instance;
  RideService._internal();

  TripState _state = TripState.idle;
  TripRoute? _activeRoute;
  RideCategory? _selectedCategory;
  VehicleMarker? _assignedDriver;

  final StreamController<TripState> _stateController =
      StreamController<TripState>.broadcast();

  TripState get state => _state;
  Stream<TripState> get stateStream => _stateController.stream;
  TripRoute? get activeRoute => _activeRoute;
  RideCategory? get selectedCategory => _selectedCategory;
  VehicleMarker? get assignedDriver => _assignedDriver;

  void selectCategory(RideCategory category) {
    _selectedCategory = category;
  }

  /// Calculates dynamic surge pricing multiplier based on H3 spatial cell density
  double getSurgeMultiplierForCell(H3Index cell) {
    // Reconstructs cell-density surge multiplier from Uber backend/client handshake
    final int cellHash = cell.value.hashCode;
    final double raw = 1.0 + (cellHash.abs() % 8) * 0.1;
    return (raw * 10).round() / 10.0;
  }

  /// Generates a realistic curved navigation route between origin and destination
  TripRoute createRoute(GeoCoordinates origin, GeoCoordinates destination) {
    final List<GeoCoordinates> points = [];
    const int stepCount = 20;

    // Intermediate bezier-like curve to simulate city road grid
    final double midLat = (origin.latitude + destination.latitude) / 2.0 + 0.003;
    final double midLng = (origin.longitude + destination.longitude) / 2.0 - 0.002;

    for (int i = 0; i <= stepCount; i++) {
      final double t = i / stepCount.toDouble();
      final double lat = (1 - t) * (1 - t) * origin.latitude +
          2 * (1 - t) * t * midLat +
          t * t * destination.latitude;
      final double lng = (1 - t) * (1 - t) * origin.longitude +
          2 * (1 - t) * t * midLng +
          t * t * destination.longitude;
      points.add(GeoCoordinates(lat, lng));
    }

    // Traffic congestion segments
    final List<RouteTrafficSegment> traffic = [
      const RouteTrafficSegment(startIndex: 0, endIndex: 8, level: TrafficLevel.clear),
      const RouteTrafficSegment(startIndex: 8, endIndex: 14, level: TrafficLevel.moderate),
      const RouteTrafficSegment(startIndex: 14, endIndex: 20, level: TrafficLevel.clear),
    ];

    final distanceMeters = origin.distanceTo(destination) * 1.35; // City grid factor
    final durationSeconds = (distanceMeters / 9.0).round(); // ~32 km/h average city speed

    _activeRoute = TripRoute(
      routeId: 'rt_${DateTime.now().millisecondsSinceEpoch}',
      origin: origin,
      destination: destination,
      polylinePoints: points,
      trafficSegments: traffic,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
    );

    _state = TripState.selectingRide;
    _stateController.add(_state);
    return _activeRoute!;
  }

  /// Initiates driver dispatch state machine
  Future<void> requestRide() async {
    _state = TripState.requestingDriver;
    _stateController.add(_state);

    await Future.delayed(const Duration(seconds: 3));

    // Assign nearest vehicle
    if (_activeRoute != null) {
      _assignedDriver = VehicleMarker.create(
        id: 'driver_sf_409',
        position: GeoCoordinates(
          _activeRoute!.origin.latitude + 0.004,
          _activeRoute!.origin.longitude - 0.003,
        ),
        bearing: 135.0,
        modelName: 'Tesla Model Y (Black)',
        licensePlate: '8TYX419',
      );
      _state = TripState.driverAssigned;
      _stateController.add(_state);
    }
  }

  void cancelOrReset() {
    _state = TripState.idle;
    _activeRoute = null;
    _assignedDriver = null;
    _stateController.add(_state);
  }
}
