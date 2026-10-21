import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
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

    // Reevaluate the anchor alarm whenever the live GPS provider rebuilds this screen.
    if (currentPosition != null && config != null && config.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<AnchorWatchProvider>().updatePosition(currentPosition);
        }
      });
    }

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
                          'Pour surveiller en arrière-plan, autorise la localisation « Toujours » dans les réglages iOS/Android. Le système peut limiter le GPS ou le son.',
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: anchorProvider.isAlarmTriggered
                    ? null
                    : anchorProvider.isSoundTestActive
                        ? anchorProvider.stopAlarmSoundTest
                        : anchorProvider.testAlarmSound,
                icon: Icon(
                  anchorProvider.isSoundTestActive
                      ? Icons.stop_circle_outlined
                      : Icons.volume_up_rounded,
                ),
                label: Text(
                  anchorProvider.isSoundTestActive
                      ? 'ARRÊTER LE TEST SONORE'
                      : 'TESTER LE SON DE L’ALARME',
                ),
              ),
              if (!anchorProvider.isAlarmTriggered)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    'Lance un son continu jusqu’à l’arrêt manuel. Vérifie le volume et le mode silencieux du téléphone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
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
              if (anchorProvider.isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  'Récupération du dernier point de mouillage enregistré…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
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
                  onPressed: anchorProvider.isLoading
                      ? null
                      : () async {
                    if (isMouille) {
                      await anchorProvider.raiseAnchor();
                    } else if (currentPosition != null) {
                      final permission = await Geolocator.checkPermission();
                      if (!context.mounted) return;
                      if (permission != LocationPermission.always) {
                        final continueWithoutBackground = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Autoriser le suivi en arrière-plan'),
                            content: const Text(
                              'La localisation « Toujours » est nécessaire pour que KipMarine puisse continuer à surveiller le mouillage lorsque l’application n’est plus à l’écran. '
                              'Dans les réglages du téléphone, autorise la localisation en permanence et active les notifications si elles sont proposées. '
                              'Si tu continues sans cette autorisation, l’alarme en arrière-plan n’est pas garantie.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('Annuler'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: const Text('Continuer'),
                              ),
                            ],
                          ),
                        );
                        if (continueWithoutBackground != true || !context.mounted) {
                          return;
                        }
                      }
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
