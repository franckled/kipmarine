import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/mediterranean_sea_painter.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'Chargement…';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = '${info.version} (${info.buildNumber})');
    } catch (_) {
      if (!mounted) return;
      setState(() => _version = 'Indisponible');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? const Color(0xFF0B4A58) : const Color(0xFF078CA5),
                    isDark ? const Color(0xFF073042) : const Color(0xFF073042),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: isDark ? 0.12 : 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: MediterraneanSeaPainter()),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF061C27).withValues(alpha: 0.10),
                            const Color(0xFF061C27).withValues(alpha: 0.30),
                            const Color(0xFF061C27).withValues(alpha: 0.94),
                          ],
                          stops: const [0, 0.38, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -34,
                    top: -42,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 22,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 22,
                    bottom: -55,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mobOrange.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.sailing_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'KipMarine',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            letterSpacing: -0.7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'La Méditerranée comme horizon.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.94),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Les essentiels de la navigation, à portée de main.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.76),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.waves_rounded,
                                  size: 16, color: Color(0xFF80E8E7)),
                              SizedBox(width: 8),
                              Text(
                                'NAVIGATION · SÉCURITÉ · LIBERTÉ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'L’application',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Créateur',
                    value: 'Franck LE DUFF',
                  ),
                  const Divider(height: 1, indent: 64),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Année de création',
                    value: '2026',
                  ),
                  const Divider(height: 1, indent: 64),
                  _InfoRow(
                    icon: Icons.phone_iphone_rounded,
                    label: 'Version installée',
                    value: _version,
                    accent: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.surface.withValues(alpha: 0.75)
                    : const Color(0xFFEAF6F8),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.65),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sailing_outlined, color: colors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'KipMarine est un outil d’aide à la navigation. '
                      'Ses indications ne remplacent ni les cartes et '
                      'publications nautiques officielles, ni les instruments '
                      'de bord. Vérifiez toujours les informations avant '
                      'toute décision en mer.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'FAIT AVEC PASSION POUR LA MER',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: colors.primary, size: 21),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: accent ? colors.primary : colors.onSurface,
              ),
        ),
      ),
    );
  }
}
