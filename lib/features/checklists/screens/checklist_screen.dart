import 'package:flutter/material.dart';

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
      'title': 'Navigation côtière (< 6 milles)',
      'items': [
        'Équipement individuel de flottabilité (gilet 100 N par personne)',
        'Moyen de repérage lumineux (lampe torche ou flash étanche)',
        'Dispositif d’assèchement manuel (écope ou pompe de cale)',
        'Moyen de remorquage (bout de remorque adapté)',
        'Ligne de mouillage avec ancre adaptée',
        'Annuaire des marées et document officiel de synthèse',
        '3 feux de détresse rouges à main',
        'Coupe-circuit de sécurité (si moteur hors-bord)',
      ],
    },
    {
      'title': 'Navigation semi-hauturière (6 à 60 milles)',
      'items': [
        'Tout le matériel côtier complet',
        'Gilets de sauvetage 150 N avec harnais et sous-cutale',
        '3 fusées à parachute et 2 fumigènes flottants',
        'Radeau de survie hauturier (ISO 9650-1)',
        'VHF fixe certifiée avec fonction ASN (DSC)',
        'Carte marine officielle papier ou électronique (GPS)',
        'Compas magnétique étalonné',
        'Trousse de secours médicale conforme',
      ],
    },
    {
      'title': 'Navigation hauturière (> 60 milles)',
      'items': [
        'Tout le matériel semi-hauturier complet',
        'Balise de détresse satellite EPIRB 406 MHz',
        'VHF portable étanche supplémentaire',
        'Lignes de vie installées sur le pont',
        'Récepteur météo marine ou modem satellite / GRIB',
        'Gilets 275 N gonflables automatiques',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final currentCat = _checklistCategories[_categoryIndex];
    final List<String> items = currentCat['items'];
    final checkedCount = items
        .where((item) => _checkedItems['${_categoryIndex}_$item'] == true)
        .length;
    final progress = items.isEmpty ? 0.0 : checkedCount / items.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Check-lists sécurité')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Côtier',
                      isSelected: _categoryIndex == 0,
                      onTap: () => setState(() => _categoryIndex = 0),
                    ),
                    _TabButton(
                      label: 'Semi-haut.',
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
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF0B4A58), Color(0xFF073042)]
                        : const [Color(0xFF12AFCB), Color(0xFF073B55)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fact_check_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            currentCat['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$checkedCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 3),
                          child: Text(
                            '/ ${items.length} vérifiés',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (progress == 1)
                          const Icon(Icons.verified_rounded,
                              color: Color(0xFF80F0C4), size: 25)
                        else
                          Text(
                            '${(progress * 100).round()} %',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.20),
                        color: const Color(0xFF80F0C4),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'À vérifier avant le départ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$checkedCount/${items.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final key = '${_categoryIndex}_$item';
                    final isChecked = _checkedItems[key] ?? false;

                    return Material(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(17),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(17),
                        onTap: () => setState(
                          () => _checkedItems[key] = !isChecked,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: isChecked
                                  ? colors.primary.withValues(alpha: 0.55)
                                  : theme.dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? colors.primary
                                      : colors.primary.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  isChecked
                                      ? Icons.check_rounded
                                      : Icons.check_box_outline_blank_rounded,
                                  size: 19,
                                  color: isChecked
                                      ? Colors.white
                                      : colors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    item,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isChecked
                                          ? colors.onSurfaceVariant
                                          : colors.onSurface,
                                      fontWeight: FontWeight.w600,
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Liste indicative : vérifiez les exigences réglementaires '
                'officielles applicables à votre navigation.',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
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

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: Material(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.25)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
