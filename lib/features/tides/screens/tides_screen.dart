import 'package:flutter/material.dart';

class TidesScreen extends StatefulWidget {
  const TidesScreen({super.key});

  @override
  State<TidesScreen> createState() => _TidesScreenState();
}

class _TidesScreenState extends State<TidesScreen> {
  final List<String> _ports = const [
    'Saint-Florent',
    'Bastia',
    'Calvi',
    'Ajaccio',
    'Bonifacio',
    'Brest',
  ];

  String _selectedPort = 'Saint-Florent';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Marées & Courants',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.waves_rounded, color: colors.primary, size: 28),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PORT DE RÉFÉRENCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPort,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    items: _ports.map((port) {
                      return DropdownMenuItem<String>(
                        value: port,
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: colors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(port),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (port) {
                      if (port == null) return;
                      setState(() => _selectedPort = port);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Icon(Icons.waves_rounded, size: 48, color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Prévisions de marée',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedPort,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.primary),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: colors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Les données de marée ne sont pas encore connectées. '
                              'Les horaires, hauteurs et coefficients ne seront affichés '
                              'qu’après intégration d’une source de prévisions fiable.',
                              style: TextStyle(color: colors.onSurface, fontSize: 13, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: theme.dividerColor),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, color: colors.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Prochaines pleines et basses mers',
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.height_rounded, color: colors.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hauteur et coefficient de marée',
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Important : la sélection change le port affiché, mais ne fournit pas encore '
                'de prévisions locales. Ne pas utiliser cet écran pour préparer une navigation '
                'tant que des données officielles ne sont pas intégrées.',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
