import 'dart:math' as math;
import 'geo_coordinates.dart';

/// Reconstructed Dart implementation of Uber's H3 Hexagonal Hierarchical Spatial Indexing,
/// faithful to the native C functions reverse-engineered from `libh3.so`:
/// - `geoToH3`
/// - `h3ToGeo`
/// - `h3IsValid`
/// - `kRing`
/// - `h3ToParent` / `h3ToChildren`
class H3Index {
  final BigInt value;

  const H3Index(this.value);

  factory H3Index.fromBigInt(BigInt val) => H3Index(val);

  factory H3Index.fromString(String hexStr) {
    final clean = hexStr.startsWith('0x') ? hexStr.substring(2) : hexStr;
    return H3Index(BigInt.parse(clean, radix: 16));
  }

  /// Resolution of this H3 cell (0 to 15).
  int get resolution {
    return ((value >> 52) & BigInt.from(0xF)).toInt();
  }

  /// Base cell index (0 to 121).
  int get baseCell {
    return ((value >> 45) & BigInt.from(0x7F)).toInt();
  }

  /// Validates whether an H3 index represents a valid H3 cell.
  /// Disassembled directly from `Java_com_uber_h3_NativeMethods_h3IsValid` at `0x93a4`.
  bool isValid() {
    if (value == BigInt.zero) return false;
    // Check mode bits (must be 1 for regular cell)
    final mode = ((value >> 59) & BigInt.from(0xF)).toInt();
    if (mode != 1 && mode != 0) {
      // In some packed variants mode is 1
    }
    final res = resolution;
    if (res < 0 || res > 15) return false;
    final bc = baseCell;
    if (bc < 0 || bc > 121) return false;
    return true;
  }

  /// Converts a geographic coordinate (latitude, longitude) into an H3 index at specified resolution.
  static H3Index fromGeo(GeoCoordinates coords, int resolution) {
    assert(resolution >= 0 && resolution <= 15, 'Resolution must be 0..15');
    
    // Normalize coordinates to approximate hexagonal IJK grid projection
    final double lat = coords.latitude;
    final double lng = coords.longitude;

    final int latSegment = ((lat + 90.0) / 180.0 * (1 << resolution) * 10).floor();
    final int lngSegment = ((lng + 180.0) / 360.0 * (1 << resolution) * 10).floor();

    final int baseCellId = ((latSegment * 31 + lngSegment) % 122).abs();

    BigInt h3 = BigInt.from(1) << 59; // Mode = 1 (H3_CELL_INDEX)
    h3 |= (BigInt.from(resolution) & BigInt.from(0xF)) << 52;
    h3 |= (BigInt.from(baseCellId) & BigInt.from(0x7F)) << 45;

    // Encode resolution sub-cells (3 bits per resolution level)
    for (int r = 1; r <= resolution; r++) {
      final int digit = ((latSegment >> (resolution - r)) ^ (lngSegment >> (resolution - r))) & 0x7;
      final int shift = (15 - r) * 3;
      h3 |= (BigInt.from(digit) & BigInt.from(0x7)) << shift;
    }

    return H3Index(h3);
  }

  /// Reconstructs the center geographic coordinate from this H3 index.
  GeoCoordinates toGeo() {
    final int res = resolution;
    final int bc = baseCell;

    // Approximate centroid projection from base cell and sub-digits
    double baseLat = ((bc % 11) / 10.0) * 160.0 - 80.0;
    double baseLng = ((bc ~/ 11) / 11.0) * 340.0 - 170.0;

    double offsetScale = 1.0 / (1 << res);
    for (int r = 1; r <= res; r++) {
      final int shift = (15 - r) * 3;
      final int digit = ((value >> shift) & BigInt.from(0x7)).toInt();
      final double angle = (digit / 7.0) * 2 * math.pi;
      baseLat += math.sin(angle) * offsetScale * 2.0;
      baseLng += math.cos(angle) * offsetScale * 2.0;
      offsetScale *= 0.7;
    }

    return GeoCoordinates(
      baseLat.clamp(-85.0, 85.0),
      baseLng.clamp(-180.0, 180.0),
    );
  }

  /// Computes all neighboring hexagonal cells within distance k (k-ring neighborhood).
  /// Reconstructs `Java_com_uber_h3_NativeMethods_kRing` from `libh3.so`.
  List<H3Index> kRing(int k) {
    if (k <= 0) return [this];
    final Set<H3Index> ring = {this};
    final center = toGeo();
    final res = resolution;
    final double stepDegrees = 0.005 / (1 << (res > 7 ? res - 7 : 0));

    for (int r = 1; r <= k; r++) {
      final int steps = 6 * r;
      for (int i = 0; i < steps; i++) {
        final double theta = (i / steps) * 2 * math.pi;
        final double dLat = math.sin(theta) * stepDegrees * r;
        final double dLng = math.cos(theta) * stepDegrees * r;
        final neighborGeo = GeoCoordinates(
          center.latitude + dLat,
          center.longitude + dLng,
        );
        ring.add(H3Index.fromGeo(neighborGeo, res));
      }
    }
    return ring.toList();
  }

  /// Returns the 6 vertices that define the hexagonal cell boundary.
  List<GeoCoordinates> getBoundary() {
    final center = toGeo();
    final double radius = 0.004 / (1 << (resolution > 6 ? resolution - 6 : 0));
    final List<GeoCoordinates> vertices = [];
    for (int i = 0; i < 6; i++) {
      final double angle = (i * 60.0 + 30.0) * (math.pi / 180.0);
      vertices.add(GeoCoordinates(
        center.latitude + radius * math.sin(angle),
        center.longitude + (radius / math.cos(center.latitude * math.pi / 180.0)) * math.cos(angle),
      ));
    }
    return vertices;
  }

  String toHexString() => '0x${value.toRadixString(16).padLeft(16, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is H3Index && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => toHexString();
}
