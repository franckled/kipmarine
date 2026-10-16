import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/navigation/models/navigation_data.dart';

class GpsSignalBadge extends StatelessWidget {
  final GpsSignalStatus status;
  final double accuracy;

  const GpsSignalBadge({
    super.key,
    required this.status,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;

    switch (status) {
      case GpsSignalStatus.excellent:
        badgeColor = AppColors.okGreen;
        label = 'GPS EXCELLENT (±${accuracy.toStringAsFixed(1)}m)';
        break;
      case GpsSignalStatus.good:
        badgeColor = AppColors.okGreen;
        label = 'GPS BON (±${accuracy.toStringAsFixed(1)}m)';
        break;
      case GpsSignalStatus.fair:
        badgeColor = AppColors.warningOrange;
        label = 'GPS MOYEN (±${accuracy.toStringAsFixed(1)}m)';
        break;
      case GpsSignalStatus.poor:
      case GpsSignalStatus.lost:
        badgeColor = AppColors.alertRed;
        label = 'GPS FAIBLE (±${accuracy.toStringAsFixed(1)}m)';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(40),
        border: Border.all(color: badgeColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.satellite_alt_rounded, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
