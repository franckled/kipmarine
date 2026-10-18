import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class TidesScreen extends StatefulWidget {
  const TidesScreen({super.key});

  @override
  State<TidesScreen> createState() => _TidesScreenState();
}

class _TidesScreenState extends State<TidesScreen> {
  static const List<String> _ports = [
    'Saint-Florent', 'Bastia', 'Calvi', 'L’Île-Rousse', 'Ajaccio',
    'Bonifacio', 'Porto-Vecchio', 'Propriano', 'Marseille', 'Toulon', 'Brest',
  ];
  String _selectedPort = 'Saint-Florent';

  Future<void> _openOfficialTides() async {
    final uri = Uri.parse('https://maree.shom.fr/');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir le site officiel du SHOM.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Marées & courants', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.waves, color: AppColors.primaryTeal, size: 24))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('PORT OU SECTEUR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.6)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPort,
                  isExpanded: true,
                  items: _ports.map((port) => DropdownMenuItem(value: port, child: Text(port))).toList(),
                  onChanged: (value) { if (value != null) setState(() => _selectedPort = value); },
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [Icon(Icons.info_outline, color: AppColors.primaryTeal), SizedBox(width: 8), Expanded(child: Text('Prédictions officielles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)))]),
                const SizedBox(height: 12),
                Text('Port sélectionné : $_selectedPort', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                const Text(
                  'Cette version de KipMarine contenait des hauteurs et horaires fictifs. Ils ont été retirés pour éviter toute confusion en navigation. Le port choisi ici sert de repère : il faudra aussi le sélectionner sur le site officiel. Les prédictions intégrées à l’application nécessitent une source de données autorisée.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _openOfficialTides,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Consulter le SHOM', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.iconBgCyan, borderRadius: BorderRadius.circular(14)),
              child: const Text(
                'À noter : le SHOM propose des services de prédiction de marée par port et en tout point. L’intégration directe dans KipMarine demandera une clé d’accès autorisée. Ne vous fiez pas à une estimation non vérifiée pour la sécurité de la navigation.',
                style: TextStyle(color: AppColors.textDark, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
