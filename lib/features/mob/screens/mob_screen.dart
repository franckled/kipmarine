import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/marine_formatter.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../providers/mob_provider.dart';

class MobScreen extends StatelessWidget {
  const MobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobProvider = context.watch<MobProvider>();
    final navProvider = context.watch<NavigationProvider>();
    final currentPos = navProvider.currentData;
    final mobPos = mobProvider.mobPosition;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final distance = currentPos != null ? mobProvider.getDistanceToMob(currentPos) : 0.0;
    final bearing = currentPos != null ? mobProvider.getBearingToMob(currentPos) : 0.0;
    final cardinal = mobProvider.getCardinal(bearing);

    final duration = mobProvider.elapsedTime;
    final timeStr = '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.mobOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HOMME À LA MER',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: AppColors.mobOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.mobOrange.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: (bearing * pi / 180),
                      child: const Icon(
                        Icons.navigation_rounded,
                        color: AppColors.mobOrange,
                        size: 110,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${distance.round()} m',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        'DISTANCE',
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${bearing.round()}°',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        'CAP $cardinal',
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      mobPos != null
                          ? '${MarineFormatter.formatLatitude(mobPos.latitude)}   ${MarineFormatter.formatLongitude(mobPos.longitude)}'
                          : 'Position non disponible',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mobProvider.mobTimestamp != null
                          ? 'Position enregistrée à ${mobProvider.mobTimestamp!.hour.toString().padLeft(2, '0')}:${mobProvider.mobTimestamp!.minute.toString().padLeft(2, '0')}'
                          : 'Heure de position indisponible',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mobOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    mobProvider.cancelMob();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '✕ MAINTENIR POUR ANNULER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
