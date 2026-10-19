import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ride_category.dart';

class RideCategoryCard extends StatelessWidget {
  final RideCategory category;
  final bool isSelected;
  final double distanceKm;
  final double surgeMultiplier;
  final VoidCallback onSelect;

  const RideCategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.distanceKm,
    required this.surgeMultiplier,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final fare = category.calculateFare(distanceKm, surgeMultiplier);

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceDarkElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Vehicle Icon Placeholder
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForTier(category.tier),
                color: AppColors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Ride Title & Tagline
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.person,
                        size: 13,
                        color: AppColors.gray400,
                      ),
                      Text(
                        '${category.capacity}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.estimatedEtaMinutes} mins away • ${category.tagline}',
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

            // Price & Surge indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${fare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                if (surgeMultiplier > 1.0)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.uberGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${surgeMultiplier}x Surge',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.uberGold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTier(RideTier tier) {
    switch (tier) {
      case RideTier.uberX:
        return Icons.directions_car;
      case RideTier.comfort:
        return Icons.airline_seat_recline_extra;
      case RideTier.black:
        return Icons.local_taxi;
      case RideTier.uberXL:
        return Icons.airport_shuttle;
      case RideTier.green:
        return Icons.electric_car;
    }
  }
}
