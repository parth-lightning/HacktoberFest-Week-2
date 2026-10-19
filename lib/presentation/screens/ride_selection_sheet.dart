import 'package:flutter/material.dart';
import '../../core/spatial/h3_index.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ride_category.dart';
import '../../models/trip_route.dart';
import '../../services/ride_service.dart';
import '../widgets/ride_category_card.dart';

class RideSelectionSheet extends StatefulWidget {
  final TripRoute route;
  final H3Index originH3Cell;
  final VoidCallback onConfirmRide;
  final VoidCallback onCancel;

  const RideSelectionSheet({
    super.key,
    required this.route,
    required this.originH3Cell,
    required this.onConfirmRide,
    required this.onCancel,
  });

  @override
  State<RideSelectionSheet> createState() => _RideSelectionSheetState();
}

class _RideSelectionSheetState extends State<RideSelectionSheet> {
  late RideCategory _selected;
  late double _surgeMultiplier;

  @override
  void initState() {
    super.initState();
    _selected = kDefaultRideCategories.first;
    _surgeMultiplier = RideService().getSurgeMultiplierForCell(widget.originH3Cell);
    RideService().selectCategory(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Route Metrics Bar
          Row(
            children: [
              Text(
                '${widget.route.distanceKm.toStringAsFixed(1)} km • ~${widget.route.durationMinutes} min',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              if (_surgeMultiplier > 1.0)
                Row(
                  children: [
                    const Icon(Icons.bolt, color: AppColors.uberGold, size: 16),
                    Text(
                      '${_surgeMultiplier}x Surge Pricing',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.uberGold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Ride Options List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: kDefaultRideCategories.length,
              itemBuilder: (context, index) {
                final cat = kDefaultRideCategories[index];
                return RideCategoryCard(
                  category: cat,
                  isSelected: cat.id == _selected.id,
                  distanceKm: widget.route.distanceKm,
                  surgeMultiplier: _surgeMultiplier,
                  onSelect: () {
                    setState(() => _selected = cat);
                    RideService().selectCategory(cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Payment Option Bar
          Row(
            children: [
              const Icon(Icons.credit_card, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Uber Pay •••• 4242',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.gray400, size: 20),
                onPressed: widget.onCancel,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Confirm Button
          ElevatedButton(
            onPressed: widget.onConfirmRide,
            child: Text(
              'Choose ${_selected.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
