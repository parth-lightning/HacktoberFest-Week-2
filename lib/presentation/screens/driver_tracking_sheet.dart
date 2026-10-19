import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/vehicle_marker.dart';

class DriverTrackingSheet extends StatelessWidget {
  final VehicleMarker driver;
  final String categoryName;
  final VoidCallback onCancel;

  const DriverTrackingSheet({
    super.key,
    required this.driver,
    required this.categoryName,
    required this.onCancel,
  });

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
          const SizedBox(height: 14),

          // ETA & Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver is arriving in 3 mins',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Meet at the corner of Market St',
                    style: TextStyle(fontSize: 13, color: AppColors.gray400),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.uberBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'EN ROUTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.uberBlue,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderSubtle, height: 24),

          // Driver & Vehicle Information Card
          Row(
            children: [
              // Driver Avatar
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceDarkElevated,
                child: Icon(Icons.person, color: AppColors.white, size: 30),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Michael D.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.star, color: AppColors.uberGold, size: 14),
                        Text(
                          ' 4.96',
                          style: TextStyle(fontSize: 13, color: AppColors.gray400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      driver.modelName,
                      style: const TextStyle(fontSize: 13, color: AppColors.gray400),
                    ),
                  ],
                ),
              ),

              // License Plate Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  driver.licensePlate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Actions Row (Voice Call mirroring Twilio VoIP native library & In-App Messaging)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceDarkElevated,
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call (VoIP)', style: TextStyle(fontSize: 13)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Starting encrypted VoIP session via Twilio WebRTC bridge'),
                        backgroundColor: AppColors.uberBlue,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceDarkElevated,
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message', style: TextStyle(fontSize: 13)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening secure in-app message thread')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cancel Trip Button
          Center(
            child: TextButton(
              onPressed: onCancel,
              child: const Text(
                'Cancel Trip',
                style: TextStyle(
                  color: AppColors.uberRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
