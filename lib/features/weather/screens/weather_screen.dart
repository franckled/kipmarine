import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/providers/navigation_provider.dart';

/// No fabricated weather values are shown until a live forecast source is
/// connected. This prevents placeholder values being mistaken for conditions
/// at sea.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final position = context.watch<NavigationProvider>().currentData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Météo marine',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    Color.lerp(colors.primary, colors.surface, 0.35)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.waves_rounded, color: Colors.white, size: 36),
                  SizedBox(height: 16),
                  Text(
                    'Météo marine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Prévisions en direct non connectées',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cloud_off_rounded, color: colors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'KipMarine n’est pas encore relié à une source de prévisions météorologiques et de houle. '
                      'Aucune valeur de vent, de rafales ou de vagues ne sera inventée ici.',
                      style: TextStyle(
                        color: colors.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POSITION GPS',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    position == null
                        ? 'En attente d’une position GPS.'
                        : '${position.latitude.toStringAsFixed(5)}°, '
                            '${position.longitude.toStringAsFixed(5)}°',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sécurité : consulte une source météo marine actualisée avant le départ. '
              'Cet écran ne doit pas être utilisé pour décider de prendre la mer.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
