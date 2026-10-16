import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VhfChannelItem {
  final String channel;
  final String title;
  final String frequency;
  final String description;
  final Color color;

  const VhfChannelItem({
    required this.channel,
    required this.title,
    required this.frequency,
    required this.description,
    required this.color,
  });
}

class VhfScreen extends StatelessWidget {
  const VhfScreen({super.key});

  static const List<VhfChannelItem> channels = [
    VhfChannelItem(
      channel: '16',
      title: 'Détresse, urgence & appel',
      frequency: '156.800 MHz',
      description: 'Veille permanente. Appel de détresse Mayday puis dégagement sur canal de travail.',
      color: AppColors.accentTeal,
    ),
    VhfChannelItem(
      channel: '70',
      title: 'ASN / DSC (Appel numérique)',
      frequency: '156.525 MHz',
      description: 'Appel Sélectif Numérique d\'urgence. Ne pas utiliser pour les liaisons phonie.',
      color: AppColors.accentTeal,
    ),
    VhfChannelItem(
      channel: '06',
      title: 'Inter-navires & sécurité (SAR)',
      frequency: '156.300 MHz',
      description: 'Communications de sécurité entre navires et opérations de recherche et sauvetage.',
      color: AppColors.accentTeal,
    ),
    VhfChannelItem(
      channel: '13',
      title: 'Sécurité navigation (Pont à pont)',
      frequency: '156.650 MHz',
      description: 'Manœuvres, croisements et échanges de sécurité avec les navires de commerce.',
      color: AppColors.accentTeal,
    ),
    VhfChannelItem(
      channel: '09',
      title: 'Capitaineries & appel marinas',
      frequency: '156.450 MHz',
      description: 'Demande d\'emplacement, arrivée au port et services de plaisance.',
      color: AppColors.accentTeal,
    ),
    VhfChannelItem(
      channel: '72',
      title: 'Inter-navires (Privé)',
      frequency: '156.625 MHz',
      description: 'Communications privées et de courtoisie entre bateaux de plaisance.',
      color: AppColors.accentTeal,
    ),
    VhfChannelItem(
      channel: '79',
      title: 'CROSS / Bulletins météo',
      frequency: '156.975 MHz',
      description: 'Diffusion des bulletins météo réguliers (BMS) par les centres CROSS.',
      color: AppColors.primaryTeal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Canaux VHF', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.iconBgCyan,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_input_antenna_rounded, color: AppColors.primaryTeal, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.iconBgCyan,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryTeal, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Canal 16 en veille permanente. En détresse : appel sur 16 ou ASN sur 70. Vérifiez vos fréquences locales avec l\'almanach du port.',
                      style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('CANAUX ESSENTIELS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            ...channels.map((item) => _VhfCard(item: item)),
          ],
        ),
      ),
    );
  }
}

class _VhfCard extends StatelessWidget {
  final VhfChannelItem item;
  const _VhfCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.channel,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.black, fontSize: 18),
                ),
                const Text('CANAL', style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text(item.frequency, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                const SizedBox(height: 4),
                Text(item.description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
