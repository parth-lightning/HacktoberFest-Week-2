import 'package:flutter/foundation.dart';

/// Camera projection and view parameters mirroring `com/ubercab/android/map/UberProjection`.
class MapCameraState {
  final double zoom;
  final double tilt; // Pitch in degrees
  final double bearing; // Heading in degrees
  final bool enable3DBuildings;
  final bool showTraffic;
  final bool showH3Grid;

  const MapCameraState({
    this.zoom = 15.0,
    this.tilt = 45.0,
    this.bearing = 0.0,
    this.enable3DBuildings = true,
    this.showTraffic = true,
    this.showH3Grid = false,
  });

  MapCameraState copyWith({
    double? zoom,
    double? tilt,
    double? bearing,
    bool? enable3DBuildings,
    bool? showTraffic,
    bool? showH3Grid,
  }) {
    return MapCameraState(
      zoom: zoom ?? this.zoom,
      tilt: tilt ?? this.tilt,
      bearing: bearing ?? this.bearing,
      enable3DBuildings: enable3DBuildings ?? this.enable3DBuildings,
      showTraffic: showTraffic ?? this.showTraffic,
      showH3Grid: showH3Grid ?? this.showH3Grid,
    );
  }
}

/// Map style and vector layer controller mirroring:
/// `msd::android::nativeSet3DBuildingsEnabled` in `libubermaps-gl.so`.
class MapStyleService extends ChangeNotifier {
  MapCameraState _cameraState = const MapCameraState();

  MapCameraState get cameraState => _cameraState;

  void toggle3DBuildings(bool enabled) {
    _cameraState = _cameraState.copyWith(enable3DBuildings: enabled);
    notifyListeners();
  }

  void toggleTraffic(bool enabled) {
    _cameraState = _cameraState.copyWith(showTraffic: enabled);
    notifyListeners();
  }

  void toggleH3Grid(bool enabled) {
    _cameraState = _cameraState.copyWith(showH3Grid: enabled);
    notifyListeners();
  }

  void updateZoom(double delta) {
    final newZoom = (_cameraState.zoom + delta).clamp(11.0, 19.0);
    _cameraState = _cameraState.copyWith(zoom: newZoom);
    notifyListeners();
  }

  void setBearing(double bearing) {
    _cameraState = _cameraState.copyWith(bearing: bearing);
    notifyListeners();
  }
}
