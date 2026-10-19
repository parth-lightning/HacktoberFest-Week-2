import 'package:flutter/material.dart';
import '../core/spatial/geo_coordinates.dart';
import '../core/theme/app_colors.dart';

/// Traffic congestion severity for polyline segments, mirroring `TrafficSegment`.
enum TrafficLevel {
  clear,
  moderate,
  heavy,
}

/// A slice of route with associated traffic condition, mirroring `TrafficSegment`.
class RouteTrafficSegment {
  final int startIndex;
  final int endIndex;
  final TrafficLevel level;

  const RouteTrafficSegment({
    required this.startIndex,
    required this.endIndex,
    required this.level,
  });

  Color get color {
    switch (level) {
      case TrafficLevel.clear:
        return AppColors.trafficClear;
      case TrafficLevel.moderate:
        return AppColors.trafficModerate;
      case TrafficLevel.heavy:
        return AppColors.trafficHeavy;
    }
  }
}

/// Representation of a navigational route, mirroring `com/ubercab/android/map/UberPolyline`.
class TripRoute {
  final String routeId;
  final GeoCoordinates origin;
  final GeoCoordinates destination;
  final List<GeoCoordinates> polylinePoints;
  final List<RouteTrafficSegment> trafficSegments;
  final double distanceMeters;
  final int durationSeconds;

  const TripRoute({
    required this.routeId,
    required this.origin,
    required this.destination,
    required this.polylinePoints,
    required this.trafficSegments,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  double get distanceKm => distanceMeters / 1000.0;
  int get durationMinutes => (durationSeconds / 60.0).ceil();

  /// Calculates bounding box enclosing the entire route for camera framing
  GeoBounds get bounds {
    if (polylinePoints.isEmpty) {
      return GeoBounds(southwest: origin, northeast: destination);
    }
    double minLat = polylinePoints.first.latitude;
    double maxLat = polylinePoints.first.latitude;
    double minLng = polylinePoints.first.longitude;
    double maxLng = polylinePoints.first.longitude;

    for (final p in polylinePoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return GeoBounds(
      southwest: GeoCoordinates(minLat, minLng),
      northeast: GeoCoordinates(maxLat, maxLng),
    );
  }
}
