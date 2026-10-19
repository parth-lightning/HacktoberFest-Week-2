import 'package:flutter/material.dart';
import '../../core/spatial/geo_coordinates.dart';
import '../../core/theme/app_colors.dart';

class SearchDestinationBar extends StatelessWidget {
  final ValueChanged<GeoCoordinates> onDestinationSelected;

  const SearchDestinationBar({
    super.key,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Where to?" Search Bar
        GestureDetector(
          onTap: () {
            // Default target: Embarcadero Ferry Building, SF
            onDestinationSelected(const GeoCoordinates(37.7955, -122.3937));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceDarkElevated,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Where to?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: AppColors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Quick Destinations
        _buildDestinationTile(
          icon: Icons.location_on,
          title: 'Ferry Building',
          address: '1 Ferry Building, The Embarcadero, SF',
          coords: const GeoCoordinates(37.7955, -122.3937),
        ),
        const Divider(color: AppColors.borderSubtle, height: 16),
        _buildDestinationTile(
          icon: Icons.work,
          title: 'Uber HQ (Mission Bay)',
          address: '1455 3rd St, San Francisco, CA',
          coords: const GeoCoordinates(37.7699, -122.3892),
        ),
        const Divider(color: AppColors.borderSubtle, height: 16),
        _buildDestinationTile(
          icon: Icons.flight_takeoff,
          title: 'San Francisco Int\'l Airport (SFO)',
          address: 'Terminal 2, San Francisco, CA',
          coords: const GeoCoordinates(37.6213, -122.3790),
        ),
      ],
    );
  }

  Widget _buildDestinationTile({
    required IconData icon,
    required String title,
    required String address,
    required GeoCoordinates coords,
  }) {
    return InkWell(
      onTap: () => onDestinationSelected(coords),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceDarkElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray600, size: 20),
          ],
        ),
      ),
    );
  }
}
