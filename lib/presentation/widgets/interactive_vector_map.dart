import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/spatial/geo_coordinates.dart';
import '../../core/spatial/h3_index.dart';
import '../../core/theme/app_colors.dart';
import '../../models/trip_route.dart';
import '../../models/vehicle_marker.dart';
import '../../services/map_style_service.dart';

/// High-performance Vector Map Canvas simulating the GPU vector display
/// reverse-engineered from `libubermaps-gl.so`:
/// - 3D isometric building footprints & extrusion roofs
/// - Real-time traffic polyline rendering with congestion tiers
/// - Hexagonal H3 spatial index cell overlay
/// - Vehicle markers with directional heading
class InteractiveVectorMap extends StatelessWidget {
  final GeoCoordinates center;
  final MapCameraState cameraState;
  final List<VehicleMarker> vehicles;
  final TripRoute? activeRoute;
  final ValueChanged<GeoCoordinates>? onMapTap;

  const InteractiveVectorMap({
    super.key,
    required this.center,
    required this.cameraState,
    required this.vehicles,
    this.activeRoute,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: _VectorMapPainter(
          center: center,
          cameraState: cameraState,
          vehicles: vehicles,
          activeRoute: activeRoute,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _VectorMapPainter extends CustomPainter {
  final GeoCoordinates center;
  final MapCameraState cameraState;
  final List<VehicleMarker> vehicles;
  final TripRoute? activeRoute;

  _VectorMapPainter({
    required this.center,
    required this.cameraState,
    required this.vehicles,
    this.activeRoute,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Clear background
    final bgPaint = Paint()..color = AppColors.mapBackgroundDark;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final Offset screenCenter = Offset(size.width / 2, size.height / 2);
    final double scale = math.pow(2.0, cameraState.zoom - 10.0) * 12.0;

    Offset geoToScreen(GeoCoordinates p) {
      final double dx = (p.longitude - center.longitude) * scale * 100.0;
      final double dy = -(p.latitude - center.latitude) * scale * 100.0;
      return screenCenter + Offset(dx, dy);
    }

    // 2. Draw Hexagonal H3 Cells if enabled
    if (cameraState.showH3Grid) {
      final h3Cell = H3Index.fromGeo(center, 8);
      final neighbors = h3Cell.kRing(2);
      final h3Paint = Paint()
        ..color = AppColors.uberBlue.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      for (final cell in neighbors) {
        final boundary = cell.getBoundary();
        if (boundary.isNotEmpty) {
          final path = Path();
          final first = geoToScreen(boundary.first);
          path.moveTo(first.dx, first.dy);
          for (int i = 1; i < boundary.length; i++) {
            final pt = geoToScreen(boundary[i]);
            path.lineTo(pt.dx, pt.dy);
          }
          path.close();
          canvas.drawPath(path, h3Paint);
        }
      }
    }

    // 3. Draw Road Grid (simulating vector tile roads)
    final roadPaintMajor = Paint()
      ..color = AppColors.mapRoadMajor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadPaintMinor = Paint()
      ..color = AppColors.mapRoadMinor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Synthetic road grid anchored around center
    for (double i = -6; i <= 6; i++) {
      final yOffset = i * 65.0;
      canvas.drawLine(
        Offset(0, screenCenter.dy + yOffset),
        Offset(size.width, screenCenter.dy + yOffset),
        (i % 3 == 0) ? roadPaintMajor : roadPaintMinor,
      );
    }
    for (double i = -6; i <= 6; i++) {
      final xOffset = i * 75.0;
      canvas.drawLine(
        Offset(screenCenter.dx + xOffset, 0),
        Offset(screenCenter.dx + xOffset, size.height),
        (i % 3 == 0) ? roadPaintMajor : roadPaintMinor,
      );
    }

    // 4. Draw 3D Isometric Buildings if enabled (mirroring nativeSet3DBuildingsEnabled)
    if (cameraState.enable3DBuildings) {
      final buildingExtrusionPaint = Paint()
        ..color = AppColors.mapBuilding3D
        ..style = PaintingStyle.fill;
      final buildingRoofPaint = Paint()
        ..color = AppColors.mapBuildingRoof
        ..style = PaintingStyle.fill;

      const double height3D = 16.0;
      for (double gx = -4; gx <= 4; gx += 2) {
        for (double gy = -4; gy <= 4; gy += 2) {
          final double bx = screenCenter.dx + gx * 75.0 + 15.0;
          final double by = screenCenter.dy + gy * 65.0 + 12.0;
          const double bw = 45.0;
          const double bh = 38.0;

          // Extrusion wall path
          final wallPath = Path()
            ..moveTo(bx, by + bh)
            ..lineTo(bx + bw, by + bh)
            ..lineTo(bx + bw, by + bh - height3D)
            ..lineTo(bx, by + bh - height3D)
            ..close();
          canvas.drawPath(wallPath, buildingExtrusionPaint);

          // Roof footprint
          final roofRect = Rect.fromLTWH(bx, by - height3D, bw, bh);
          canvas.drawRect(roofRect, buildingRoofPaint);
        }
      }
    }

    // 5. Draw Active Route Polyline with Traffic Segments (UberPolyline & TrafficSegment)
    if (activeRoute != null && activeRoute!.polylinePoints.length >= 2) {
      final pts = activeRoute!.polylinePoints.map(geoToScreen).toList();

      // Outer glow / casing
      final casingPaint = Paint()
        ..color = AppColors.black.withOpacity(0.6)
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final routePath = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        routePath.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(routePath, casingPaint);

      // Multi-segment traffic drawing
      for (final segment in activeRoute!.trafficSegments) {
        if (segment.startIndex >= pts.length || segment.endIndex > pts.length) continue;
        final segPath = Path()..moveTo(pts[segment.startIndex].dx, pts[segment.startIndex].dy);
        for (int i = segment.startIndex + 1; i <= segment.endIndex && i < pts.length; i++) {
          segPath.lineTo(pts[i].dx, pts[i].dy);
        }
        final segPaint = Paint()
          ..color = segment.color
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
        canvas.drawPath(segPath, segPaint);
      }

      // Draw Destination Pin
      final destScreen = pts.last;
      final pinPaint = Paint()..color = AppColors.white;
      canvas.drawCircle(destScreen, 7.0, pinPaint);
      canvas.drawCircle(destScreen, 4.0, Paint()..color = AppColors.black);
    }

    // 6. Draw User Location Pin
    final userPos = geoToScreen(center);
    final pulsePaint = Paint()
      ..color = AppColors.uberBlue.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(userPos, 22.0, pulsePaint);

    final dotCasingPaint = Paint()..color = AppColors.white;
    canvas.drawCircle(userPos, 8.0, dotCasingPaint);

    final dotPaint = Paint()..color = AppColors.uberBlue;
    canvas.drawCircle(userPos, 6.0, dotPaint);

    // 7. Draw Nearby Vehicles with Directional Heading
    for (final v in vehicles) {
      final pos = geoToScreen(v.position);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(v.bearing * (math.pi / 180.0));

      // Draw Vehicle Body (top-down modern car shape)
      final carBody = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, -13, 14, 26),
        const Radius.circular(4),
      );
      canvas.drawRRect(carBody, Paint()..color = AppColors.surfaceDarkElevated);
      canvas.drawRRect(
        carBody,
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Windshield & Roof
      final windshield = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -6, 10, 8),
        const Radius.circular(2),
      );
      canvas.drawRRect(windshield, Paint()..color = AppColors.gray800);

      // Headlights
      final lightPaint = Paint()..color = AppColors.uberGold.withOpacity(0.9);
      canvas.drawCircle(const Offset(-4, -13), 1.5, lightPaint);
      canvas.drawCircle(const Offset(4, -13), 1.5, lightPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _VectorMapPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.cameraState != cameraState ||
        oldDelegate.vehicles != vehicles ||
        oldDelegate.activeRoute != activeRoute;
  }
}
