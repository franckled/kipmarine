import 'package:flutter/material.dart';
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
    final currentPosition = navProvider.currentData;
    final config = anchorProvider.config;
    final isMouille = config != null && config.isActive;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALARME DE MOUILLAGE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'DÉRIVE DÉTECTÉE !\nBateau hors du cercle de sécurité !',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Acquitter l’alarme jusqu’au retour dans le cercle',
                        icon: const Icon(
                          Icons.volume_off,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: anchorProvider.silenceAlarm,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isMouille
                          ? (anchorProvider.isAlarmTriggered
                              ? AppColors.alertRed
                              : AppColors.okGreen)
                          : colors.primary,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.anchor,
                        size: 80,
                        color: isMouille
                            ? colors.primary
                            : colors.onSurfaceVariant.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isMouille ? 'MOUILLAGE ACTIF' : 'MOUILLAGE INACTIF',
                        style: TextStyle(
                          color: isMouille
                              ? AppColors.okGreen
                              : colors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isMouille) ...[
                        Text(
                          '${config.currentDistance.toStringAsFixed(1)} m',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          'Distance de l’ancre (max. : ${config.radiusMeters.round()} m)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Positionne le bateau au-dessus de l’ancre et clique sur « Mouiller l’ancre ».',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      if (isMouille) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Le suivi GPS reste actif lorsque tu quittes cet écran, tant que KipMarine continue de recevoir les positions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!isMouille) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rayon de sécurité',
                      style: TextStyle(color: colors.onSurface, fontSize: 16),
                    ),
                    Text(
                      '${anchorProvider.targetRadiusMeters.round()} m',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: anchorProvider.targetRadiusMeters,
                  min: 10,
                  max: 150,
                  divisions: 28,
                  activeColor: colors.primary,
                  onChanged: anchorProvider.setTargetRadius,
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isMouille ? AppColors.alertRed : AppColors.okGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    isMouille ? Icons.eject : Icons.anchor,
                    size: 28,
                  ),
                  label: Text(
                    isMouille ? 'LEVER L’ANCRE' : 'MOUILLER L’ANCRE',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    if (isMouille) {
                      await anchorProvider.raiseAnchor();
                    } else if (currentPosition != null) {
                      anchorProvider.dropAnchor(currentPosition);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Attente d’une position GPS valide pour mouiller.',
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
