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

    final distance = currentPos != null ? mobProvider.getDistanceToMob(currentPos) : 0.0;
    final bearing = currentPos != null ? mobProvider.getBearingToMob(currentPos) : 0.0;
    final cardinal = mobProvider.getCardinal(bearing);

    final duration = mobProvider.elapsedTime;
    final timeStr = '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bandeau supérieur
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
                      const Text(
                        'HOMME À LA MER',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.black,
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

              // Boussole centrale indiquant la direction de l'Homme à la mer
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

              // Distance et Cap
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${distance.round()} m',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.black,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'DISTANCE',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${bearing.round()}°',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.black,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'CAP $cardinal',
                        style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Position GPS enregistrée
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      mobPos != null
                          ? '${MarineFormatter.formatLatitude(mobPos.latitude)}   ${MarineFormatter.formatLongitude(mobPos.longitude)}'
                          : '42°40.877\'N   9°25.655\'E',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Position enregistrée à ${mobProvider.mobTimestamp?.hour.toString().padLeft(2, '0')}:${mobProvider.mobTimestamp?.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bouton Appui Long pour Annuler
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
                      fontWeight: FontWeight.black,
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
