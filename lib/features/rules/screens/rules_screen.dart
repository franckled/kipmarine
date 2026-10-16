import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  int _tabIndex = 0; // 0 = RIPA, 1 = Cardinales, 2 = Feux

  final List<Map<String, String>> _ripaRules = const [
    {
      'title': 'Deux voiliers — Amures',
      'subtitle': 'Bâbord amures cède la priorité à tribord amures',
      'detail': 'Quand deux voiliers reçoivent le vent de côtés différents, celui qui est bâbord amures (recevant le vent par la gauche) doit s\'écarter de la route du voilier tribord amures.',
    },
    {
      'title': 'Deux voiliers — Même amure',
      'subtitle': 'Le voilier au vent cède la priorité à celui sous le vent',
      'detail': 'Quand deux voiliers reçoivent le vent du même côté, celui qui est au vent (du côté d\'où vient le vent) doit s\'écarter du voilier qui est sous le vent.',
    },
    {
      'title': 'Voile vs Moteur',
      'subtitle': 'Le navire à moteur s\'écarte du navire à voile',
      'detail': 'Un navire faisant route au moteur doit s\'écarter d\'un navire à voile. Attention : un voilier naviguant au moteur est juridiquement un navire à moteur.',
    },
    {
      'title': 'Routes qui se croisent (moteur)',
      'subtitle': 'Priorité au navire venant de droite (tribord)',
      'detail': 'Lorsque deux navires à moteur se croisent, celui qui voit l\'autre sur son côté TRIBORD (droite) doit s\'écarter. La manœuvre doit être franche et précoce.',
    },
    {
      'title': 'Rattrapage / Dépassement',
      'subtitle': 'Le rattrapant doit toujours s\'écarter du rattrapé',
      'detail': 'Tout navire qui en rattrape un autre (sur un secteur de plus de 22,5° sur l\'arrière du travers) doit s\'écarter, qu\'il soit à la voile ou au moteur.',
    },
  ];

  final List<Map<String, String>> _cardinales = const [
    {
      'title': 'Nord',
      'colors': 'Noir au-dessus du Jaune',
      'topmark': '▲▲ Deux cônes pointe vers le HAUT',
      'light': 'Scintillant continu (Q ou VQ)',
      'detail': 'Passer au NORD de la balise. Eaux saines au Nord.',
    },
    {
      'title': 'Est',
      'colors': 'Noir / Jaune / Noir',
      'topmark': '▲▼ Deux cônes opposés par la base',
      'light': '3 éclats rapides toutes les 10s',
      'detail': 'Passer à l\'EST de la balise. Eaux saines à l\'Est.',
    },
    {
      'title': 'Sud',
      'colors': 'Jaune au-dessus du Noir',
      'topmark': '▼▼ Deux cônes pointe vers le BAS',
      'light': '6 éclats rapides + 1 éclat long toutes les 15s',
      'detail': 'Passer au SUD de la balise. Eaux saines au Sud.',
    },
    {
      'title': 'Ouest',
      'colors': 'Jaune / Noir / Jaune',
      'topmark': '▼▲ Deux cônes opposés par la pointe',
      'light': '9 éclats rapides toutes les 15s',
      'detail': 'Passer à l\'OUEST de la balise. Eaux saines à l\'Ouest.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Règles & Balisage', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Sélecteur d'onglet
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.iconBgCyan.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'RIPA',
                      isSelected: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    _TabButton(
                      label: 'Cardinales',
                      isSelected: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _tabIndex == 0
                    ? ListView.builder(
                        itemCount: _ripaRules.length,
                        itemBuilder: (context, index) {
                          final item = _ripaRules[index];
                          return Card(
                            color: AppColors.surfaceWhite,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.cardBorder),
                            ),
                            child: ExpansionTile(
                              iconColor: AppColors.primaryTeal,
                              collapsedIconColor: AppColors.textMuted,
                              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                              subtitle: Text(item['subtitle']!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Text(item['detail']!, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4)),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: _cardinales.length,
                        itemBuilder: (context, index) {
                          final item = _cardinales[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Cardinal ${item['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryTeal)),
                                    Text(item['topmark']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Couleurs : ${item['colors']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                Text('Feu : ${item['light']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                const SizedBox(height: 6),
                                Text(item['detail']!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          );
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

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [const BoxShadow(color: Colors.black05, blurRadius: 4)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSelected ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
