import 'package:flutter_test/flutter_test.dart';
import '../lib/core/spatial/geo_coordinates.dart';
import '../lib/core/spatial/h3_index.dart';

void main() {
  group('H3 Spatial Indexing Tests (libh3.so Reconstruction)', () {
    test('h3IsValid identifies valid and invalid cells', () {
      final validCell = H3Index.fromGeo(const GeoCoordinates(37.7749, -122.4194), 8);
      expect(validCell.isValid(), isTrue);
      expect(validCell.resolution, equals(8));

      final invalidCell = H3Index(BigInt.zero);
      expect(invalidCell.isValid(), isFalse);
    });

    test('Hexadecimal representation parses and formats consistently', () {
      final cell = H3Index.fromGeo(const GeoCoordinates(40.7128, -74.0060), 7);
      final hex = cell.toHexString();
      expect(hex.startsWith('0x'), isTrue);

      final parsed = H3Index.fromString(hex);
      expect(parsed, equals(cell));
      expect(parsed.resolution, equals(7));
    });

    test('kRing produces hexagonal neighborhood ring', () {
      final cell = H3Index.fromGeo(const GeoCoordinates(37.7897, -122.4011), 8);
      final ring1 = cell.kRing(1);
      // Center + 6 immediate neighbors = 7 cells
      expect(ring1.length, equals(7));
      expect(ring1.contains(cell), isTrue);

      final ring2 = cell.kRing(2);
      // Center + 6 + 12 = 19 cells
      expect(ring2.length, equals(19));
    });

    test('getBoundary returns 6 hexagonal vertices', () {
      final cell = H3Index.fromGeo(const GeoCoordinates(37.7897, -122.4011), 8);
      final boundary = cell.getBoundary();
      expect(boundary.length, equals(6));
    });
  });
}
