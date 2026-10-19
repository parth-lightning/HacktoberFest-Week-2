# Reconstructed Uber Architecture (Flutter)

This Flutter application is reverse-engineered from and built upon the technical architectural findings of the official **Uber Android APK (`com.ubercab` v4.653.10004)**.

---

## Architecture Mapping to Native Libraries

| Native APK Binary | Reverse-Engineered Role | Flutter Architectural Layer |
| :--- | :--- | :--- |
| `libubermaps-gl.so` | Custom GPU vector map rendering, polylines, 3D buildings, dynamic camera | `lib/presentation/widgets/interactive_vector_map.dart`, `lib/models/trip_route.dart` |
| `libh3.so` | Hexagonal spatial indexing, cellular vehicle grouping, proximity search | `lib/core/spatial/h3_index.dart`, `lib/core/spatial/geo_coordinates.dart` |
| `libse.so` & `libse_loader.so` | Security Engine, root/tamper detection, emulator detection, integrity checks | `lib/core/security/security_engine.dart` |
| `libndk-crash.so` & `libndk-anr.so` | Low-level POSIX signal hooks, crash pipe logging, watchdog telemetry | `lib/core/telemetry/native_crash_bridge.dart` |
| `libml-imageproc.so` | ML buffer utilities & image preprocessing | `lib/services/location_service.dart`, `lib/models/vehicle_marker.dart` |

---

## Key Highlights

1. **Pure Dart H3 Spatial Indexing (`H3Index`)**
   - Reconstructs the exact resolution hierarchy, hexagonal cell coordinate transformations, `h3IsValid`, and `kRing` neighbor calculations that Uber's backend and app use to group drivers and calculate surge pricing.

2. **Custom Vector Map Canvas (`InteractiveVectorMap`)**
   - Implements high-performance canvas vector rendering with smooth vehicle bearing rotation, multi-segment traffic polylines (green/yellow/red congestion mirroring `TrafficSegment`), 3D building isometric projections, and custom dark/light theme shaders.

3. **Multi-Layered Security Engine (`SecurityEngine`)**
   - Emulates Uber's native device integrity validation: checks for test-keys, su binaries, debugger attachments, mock location spoofing, and generates signed integrity tokens for backend requests.

4. **Native Crash & ANR Bridge (`NativeCrashBridge`)**
   - Provides unhandled exception and slow frame detection mimicking Uber's native signal interceptor and self-pipe crash reporter.

---

## Running the Application

Ensure Flutter 3.x+ is installed, then run:

```bash
flutter pub get
flutter run
```
