import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../providers/anchor_watch_provider.dart';

class AnchorWatchScreen extends StatelessWidget {
  const AnchorWatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final anchorProvider = context.watch<AnchorWatchProvider>();
    final config = anchorProvider.config;

    final isMouille = config != null && config.isActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALARME DE MOUILLAGE', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Alerte visuelle de dérive
              if (anchorProvider.isAlarmTriggered)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'DÉRIVE DÉTECTÉE !\nBateau hors du cercle de sécurité !',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_off, color: Colors.white, size: 30),
                        onPressed: () => anchorProvider.silenceAlarm(),
                      ),
                    ],
                  ),
                ),

              // Carte / Indicateur de distance
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isMouille
                          ? (anchorProvider.isAlarmTriggered ? AppColors.alertRed : AppColors.okGreen)
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.anchor,
                        size: 80,
                        color: isMouille ? AppColors.accent : Colors.white24,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isMouille ? 'MOUILLAGE ACTIF' : 'MOUILLAGE INACTIF',
                        style: TextStyle(
                          color: isMouille ? AppColors.okGreen : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isMouille) ...[
                        Text(
                          '${config.currentDistance.toStringAsFixed(1)} m',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Distance de l\'ancre (Max : ${config.radiusMeters.round()} m)',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ] else ...[
                        const Text(
                          'Positionne le bateau au-dessus de l\'ancre et clique sur "Mouiller l\'ancre".',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Réglage du rayon de sécurité
              if (!isMouille) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rayon de sécurité :', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text(
                      '${anchorProvider.targetRadiusMeters.round()} mètres',
                      style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: anchorProvider.targetRadiusMeters,
                  min: 10,
                  max: 150,
                  divisions: 28,
                  activeColor: AppColors.accent,
                  onChanged: (val) => anchorProvider.setTargetRadius(val),
                ),
                const SizedBox(height: 10),
              ],

              // Boutons d'action principal
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMouille ? AppColors.alertRed : AppColors.okGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(isMouille ? Icons.eject : Icons.anchor, color: Colors.white, size: 28),
                  label: Text(
                    isMouille ? 'LEVER L\'ANCRE' : 'MOUILLER L\'ANCRE',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (isMouille) {
                      await anchorProvider.raiseAnchor();
                      return;
                    }

                    final position = navProvider.currentData;
                    if (position == null || !position.hasFreshPosition) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Position GPS indisponible ou périmée. Attendez un relevé récent avant de mouiller.',
                          ),
                        ),
                      );
                      return;
                    }

                    // La demande d'autorisation de notification doit se faire
                    // pendant que l'écran est actif, avant une éventuelle dérive.
                    final notificationsEnabled =
                        await anchorProvider.prepareForMonitoring();
                    if (!context.mounted) return;

                    final latestPosition = navProvider.currentData;
                    if (latestPosition == null ||
                        !latestPosition.hasFreshPosition) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Le GPS est devenu indisponible. Attendez un relevé récent avant de mouiller.',
                          ),
                        ),
                      );
                      return;
                    }

                    anchorProvider.dropAnchor(latestPosition);
                    final backgroundLocationEnabled =
                        await navProvider.hasBackgroundLocationPermission();
                    if (!context.mounted) return;

                    if (!backgroundLocationEnabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 10),
                          content: const Text(
                            'Pour surveiller le mouillage écran verrouillé, autorisez la localisation « Toujours » dans les réglages. Sans cela, la surveillance en arrière-plan n’est pas garantie.',
                          ),
                          action: SnackBarAction(
                            label: 'Réglages',
                            onPressed: () => Geolocator.openAppSettings(),
                          ),
                        ),
                      );
                    } else if (!notificationsEnabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Les notifications sont désactivées. KipMarine ne pourra pas afficher l’alerte système de secours.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
