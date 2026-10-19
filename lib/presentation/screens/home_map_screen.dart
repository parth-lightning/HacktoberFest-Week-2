import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/security/security_engine.dart';
import '../../core/spatial/geo_coordinates.dart';
import '../../core/spatial/h3_index.dart';
import '../../core/theme/app_colors.dart';
import '../../models/vehicle_marker.dart';
import '../../services/location_service.dart';
import '../../services/map_style_service.dart';
import '../../services/ride_service.dart';
import '../widgets/interactive_vector_map.dart';
import '../widgets/search_destination_bar.dart';
import '../widgets/security_badge_widget.dart';
import 'driver_tracking_sheet.dart';
import 'ride_selection_sheet.dart';
import 'security_status_dialog.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final LocationService _locationService = LocationService();
  final RideService _rideService = RideService();
  final MapStyleService _mapStyleService = MapStyleService();
  final SecurityEngine _securityEngine = SecurityEngine();

  late GeoCoordinates _cameraCenter;
  List<VehicleMarker> _nearbyVehicles = [];
  Timer? _vehicleAnimationTimer;
  SecurityAuditResult? _securityAudit;

  @override
  void initState() {
    super.initState();
    _cameraCenter = _locationService.currentLocation;

    // Initialize Security Engine
    _securityEngine.initialize().then((_) {
      if (mounted) {
        setState(() {
          _securityAudit = _securityEngine.currentStatus;
        });
      }
    });

    // Generate initial synthetic vehicles around user
    _spawnVehicles();

    // Listen to map style updates
    _mapStyleService.addListener(() {
      if (mounted) setState(() {});
    });

    // Periodic slight jitter/animation for realistic vehicle movement
    _vehicleAnimationTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) {
        setState(() {
          _nearbyVehicles = _nearbyVehicles.map((v) {
            final double dLat = (mathRandom() - 0.5) * 0.0003;
            final double dLng = (mathRandom() - 0.5) * 0.0003;
            final target = GeoCoordinates(v.position.latitude + dLat, v.position.longitude + dLng);
            return v.interpolate(target, 0.4);
          }).toList();
        });
      }
    });
  }

  double mathRandom() => (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0;

  void _spawnVehicles() {
    final positions = _locationService.generateNearbyVehiclePositions(6);
    _nearbyVehicles = List.generate(positions.length, (i) {
      return VehicleMarker.create(
        id: 'veh_$i',
        position: positions[i],
        bearing: (i * 60.0) % 360.0,
        modelName: i % 2 == 0 ? 'Toyota Camry' : 'Hyundai Ioniq 5',
        licensePlate: 'UBR${100 + i}',
      );
    });
  }

  @override
  void dispose() {
    _vehicleAnimationTimer?.cancel();
    _mapStyleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripState = _rideService.state;
    final activeRoute = _rideService.activeRoute;
    final currentH3Cell = _locationService.currentH3Cell;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Vector Map Canvas
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                final double sensitivity = 0.00003 / (_mapStyleService.cameraState.zoom / 15.0);
                _cameraCenter = GeoCoordinates(
                  _cameraCenter.latitude + details.delta.dy * sensitivity,
                  _cameraCenter.longitude - details.delta.dx * sensitivity,
                );
              });
            },
            child: InteractiveVectorMap(
              center: _cameraCenter,
              cameraState: _mapStyleService.cameraState,
              vehicles: _nearbyVehicles,
              activeRoute: activeRoute,
            ),
          ),

          // 2. Top Navigation & Status Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // App Icon / Menu Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withOpacity(0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Uber Architecture (com.ubercab v4.653.10004) Reconstructed'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Native Security Engine Audit Badge
                  SecurityBadgeWidget(
                    audit: _securityAudit,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => SecurityStatusDialog(
                          audit: _securityAudit,
                          onRefresh: () async {
                            final audit = await _securityEngine.performFullAudit();
                            if (mounted) setState(() => _securityAudit = audit);
                          },
                        ),
                      );
                    },
                  ),
                  const Spacer(),

                  // Map Feature Toggles (3D Buildings & H3 Grid)
                  _buildMapActionChip(
                    icon: Icons.view_in_ar,
                    isActive: _mapStyleService.cameraState.enable3DBuildings,
                    tooltip: 'Toggle 3D Buildings (nativeSet3DBuildingsEnabled)',
                    onTap: () => _mapStyleService.toggle3DBuildings(!_mapStyleService.cameraState.enable3DBuildings),
                  ),
                  const SizedBox(width: 8),
                  _buildMapActionChip(
                    icon: Icons.hexagon_outlined,
                    isActive: _mapStyleService.cameraState.showH3Grid,
                    tooltip: 'Toggle H3 Spatial Index Cells (libh3.so)',
                    onTap: () => _mapStyleService.toggleH3Grid(!_mapStyleService.cameraState.showH3Grid),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Zoom & Recenter Controls
          Positioned(
            right: 16,
            bottom: tripState == TripState.idle ? 290 : 380,
            child: Column(
              children: [
                _buildZoomButton(icon: Icons.add, onTap: () => _mapStyleService.updateZoom(0.8)),
                const SizedBox(height: 8),
                _buildZoomButton(icon: Icons.remove, onTap: () => _mapStyleService.updateZoom(-0.8)),
                const SizedBox(height: 8),
                _buildZoomButton(
                  icon: Icons.my_location,
                  onTap: () {
                    setState(() => _cameraCenter = _locationService.currentLocation);
                  },
                ),
              ],
            ),
          ),

          // 4. Dynamic Context Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheetContent(tripState, activeRoute, currentH3Cell),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetContent(TripState state, TripRoute? route, H3Index h3Cell) {
    switch (state) {
      case TripState.idle:
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 16)],
          ),
          child: SearchDestinationBar(
            onDestinationSelected: (dest) {
              setState(() {
                _rideService.createRoute(_locationService.currentLocation, dest);
              });
            },
          ),
        );

      case TripState.selectingRide:
        if (route == null) return const SizedBox.shrink();
        return RideSelectionSheet(
          route: route,
          originH3Cell: h3Cell,
          onConfirmRide: () {
            setState(() {
              _rideService.requestRide().then((_) {
                if (mounted) setState(() {});
              });
            });
          },
          onCancel: () {
            setState(() => _rideService.cancelOrReset());
          },
        );

      case TripState.requestingDriver:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Connecting to nearby drivers...',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Searching within H3 Cell ${h3Cell.toHexString()}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray400),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gray400,
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                onPressed: () => setState(() => _rideService.cancelOrReset()),
                child: const Text('Cancel Request'),
              ),
            ],
          ),
        );

      case TripState.driverAssigned:
      case TripState.enRoute:
        final driver = _rideService.assignedDriver;
        if (driver == null) return const SizedBox.shrink();
        return DriverTrackingSheet(
          driver: driver,
          categoryName: _rideService.selectedCategory?.name ?? 'UberX',
          onCancel: () {
            setState(() => _rideService.cancelOrReset());
          },
        );

      case TripState.completed:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMapActionChip({
    required IconData icon,
    required bool isActive,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : AppColors.surfaceDark.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? AppColors.black : AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}
