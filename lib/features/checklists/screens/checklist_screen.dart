import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  int _categoryIndex = 0;
  final Map<String, bool> _checkedItems = {};

  final List<Map<String, dynamic>> _checklistCategories = [
    {
      'title': 'Navigation Côtière (< 6 milles)',
      'items': [
        'Équipement individuel de flottabilité (Gilet 100N par personne)',
        'Moyen de repérage lumineux (Lampe torche ou flash étanche)',
        'Dispositif d\'assèchement manuel (Écope ou pompe de cale)',
        'Moyen de remorquage (Bout de remorque adapté)',
        'Ligne de mouillage avec ancre adaptée',
        'Annuaire des marées & document officiel de synthèse',
        '3 feux de détresses rouges à main',
        'Coupe-circuit de sécurité (Si moteur HF)',
      ],
    },
    {
      'title': 'Navigation Semi-Hauturière (6 à 60 milles)',
      'items': [
        'Tout le matériel Côtier complet',
        'Gilets de sauvetage 150N avec harnais et sous-cutale',
        '3 fusées à parachute & 2 fumigènes flottants',
        'Radeau de survie hauturier (ISO 9650-1)',
        'VHF fixe certifiée avec fonction ASN (DSC)',
        'Carte marine officielle papier ou électronique (GPS)',
        'Compas magnétique étalonné',
        'Trousse de secours médicale conforme',
      ],
    },
    {
      'title': 'Navigation Hauturière (> 60 milles)',
      'items': [
        'Tout le matériel Semi-Hauturier complet',
        'Balise de détresse satellite EPIRB 406 MHz',
        'VHF portable étanche supplémentaire',
        'Lignes de vie installées sur le pont',
        'Récepteur météo marine ou modem satellite / GRIB',
        'Gilets 275N gonflables automatique',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentCat = _checklistCategories[_categoryIndex];
    final List<String> items = currentCat['items'];
    final checkedCount = items.where((item) => _checkedItems['${_categoryIndex}_$item'] == true).length;
    final progress = items.isEmpty ? 0.0 : checkedCount / items.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Check-lists Sécurité', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.iconBgCyan.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Côtier',
                      isSelected: _categoryIndex == 0,
                      onTap: () => setState(() => _categoryIndex = 0),
                    ),
                    _TabButton(
                      label: 'Semi-hauturier',
                      isSelected: _categoryIndex == 1,
                      onTap: () => setState(() => _categoryIndex = 1),
                    ),
                    _TabButton(
                      label: 'Hauturier',
                      isSelected: _categoryIndex == 2,
                      onTap: () => setState(() => _categoryIndex = 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentCat['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                        ),
                        Text(
                          '$checkedCount / ${items.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryTeal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.iconBgCyan,
                      color: progress == 1.0 ? AppColors.okGreen : AppColors.primaryTeal,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final key = '${_categoryIndex}_$item';
                    final isChecked = _checkedItems[key] ?? false;

                    return Card(
                      color: AppColors.surfaceWhite,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                      child: CheckboxListTile(
                        activeColor: AppColors.primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isChecked ? AppColors.textMuted : AppColors.textDark,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        value: isChecked,
                        onChanged: (val) {
                          setState(() {
                            _checkedItems[key] = val ?? false;
                          });
                        },
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
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isSelected ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
