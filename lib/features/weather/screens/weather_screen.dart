import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Météo marine', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // Carte Fichier GRIB
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.iconBgOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sim_card_download, color: Colors.orange),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fichier GRIB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                        Text('Importer vent & mer hors-ligne', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Carte Vent Principal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryTeal, AppColors.primaryTealDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('VENT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.navigation, color: Colors.white, size: 40),
                      const SizedBox(width: 12),
                      const Text('9', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
                      const SizedBox(width: 6),
                      const Text('nds', style: TextStyle(fontSize: 20, color: Colors.white70, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Force 3 · E (94°)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const Text('Rafales 19 nds', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Triplet : Ciel / Température / Pression
            Row(
              children: [
                _WeatherMiniTile(icon: Icons.wb_sunny_outlined, label: 'Ciel clair', sub: 'CIEL'),
                const SizedBox(width: 10),
                _WeatherMiniTile(icon: Icons.thermostat, label: '24°C', sub: 'TEMPÉRATURE'),
                const SizedBox(width: 10),
                _WeatherMiniTile(icon: Icons.speed, label: '1001 hPa', sub: 'PRESSION'),
              ],
            ),

            const SizedBox(height: 16),

            // État de la mer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('État de la mer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('0.4 m', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                          Text('Hauteur vagues', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('3 s', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                          Text('Période', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('ENE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                          Text('Direction', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text('Houle : 0.3 m · mer du vent 0.0 m', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherMiniTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;

  const _WeatherMiniTile({required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryTeal, size: 22),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
            Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
