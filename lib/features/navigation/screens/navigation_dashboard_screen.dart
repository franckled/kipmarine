
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/marine_formatter.dart';
import '../../../core/widgets/mediterranean_sea_painter.dart';
import '../providers/navigation_provider.dart';
import '../../mob/providers/mob_provider.dart';
import '../../mob/screens/mob_screen.dart';
import '../../compass/screens/compass_screen.dart';
import '../../anchor_watch/screens/anchor_watch_screen.dart';
import '../../vhf/screens/vhf_screen.dart';
import '../../checklists/screens/checklist_screen.dart';
import '../../rules/screens/rules_screen.dart';
import '../../tides/screens/tides_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../about/screens/about_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../logbook/screens/logbook_screen.dart';
import '../../map/screens/marine_map_screen.dart';

class NavigationDashboardScreen extends StatefulWidget {
  const NavigationDashboardScreen({super.key});

  @override
  State<NavigationDashboardScreen> createState() =>
      _NavigationDashboardScreenState();
}

class _NavigationDashboardScreenState
    extends State<NavigationDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NavigationProvider>().startTracking();
      }
    });
  }

  String _getFormattedDate() {
    final now = DateTime.now();

    const days = [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];

    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<NavigationProvider>(
          builder: (context, navProvider, child) {
            final data = navProvider.currentData;

            final hasValidCourse =
                data != null && data.hasValidCourse;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête : titre, date et actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF12CFE3), Color(0xFF0787A6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.sailing_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'KipMarine',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 48, top: 2),
                            child: Text(
                              _getFormattedDate(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Personnaliser KipMarine',
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              foregroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.tune_rounded),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_boat_filled_rounded,
                              color: AppColors.primaryTeal,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mobOrange,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'MOB',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: () {
                              final navData = context
                                  .read<NavigationProvider>()
                                  .currentData;

                              if (navData != null) {
                                context
                                    .read<MobProvider>()
                                    .triggerMob(navData);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MobScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Attente du signal GPS pour le point MOB...',
                                    ),
                                    backgroundColor: AppColors.mobOrange,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),

                  const SizedBox(height: 20),

                  // Carte vitesse SOG, COG et position GPS — image à bord perdu
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: Theme.of(context).brightness == Brightness.dark
                            ? const [Color(0xFF0787A6), Color(0xFF061C27)]
                            : const [Color(0xFF12AFCB), Color(0xFF073B55)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.zero,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.zero,
                            child: Image.asset(
                              'assets/images/mediterranean_hero.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (_, __, ___) => const CustomPaint(
                                painter: MediterraneanSeaPainter(),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.zero,
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFF061C27).withValues(alpha: 0.72),
                                  const Color(0xFF061C27).withValues(alpha: 0.25),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -10,
                          top: -10,
                          child: Icon(
                            Icons.explore_outlined,
                            size: 130,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'VITESSE GPS · SOG',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.13),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: data != null
                                              ? const Color(0xFF64F2C2)
                                              : navProvider.isTracking
                                                  ? Colors.amber
                                                  : Colors.white54,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        data != null
                                            ? 'GPS connecté'
                                            : navProvider.isTracking
                                                ? 'Recherche GPS'
                                                : 'GPS inactif',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  data != null
                                      ? data.speedInKnots.toStringAsFixed(1)
                                      : '--',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'nds',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // COG : cap fondé sur le déplacement GPS
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasValidCourse
                                          ? MarineFormatter.formatHeading(
                                              data.heading!,
                                            )
                                          : '---°',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'COG',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white60,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                Container(
                                  height: 36,
                                  width: 1,
                                  color: Colors.white24,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                ),

                                // Position GPS réelle, sans coordonnées fictives
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'POSITION GPS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white60,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        data != null
                                            ? MarineFormatter.formatLatitude(
                                                data.latitude,
                                              )
                                            : '--',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        data != null
                                            ? MarineFormatter.formatLongitude(
                                                data.longitude,
                                              )
                                            : '--',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                  const SizedBox(height: 24),

                  // Grille des modules
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.05,
                    children: [
                      _GridCard(
                        icon: Icons.anchor_rounded,
                        iconBg: const Color(0xFFDDF7FA),
                        iconColor: const Color(0xFF008DA7),
                        title: 'Mouillage',
                        subtitle: 'Alarme d’évitage',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AnchorWatchScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.waves_rounded,
                        iconBg: const Color(0xFFDDF7FA),
                        iconColor: const Color(0xFF008DA7),
                        title: 'Marées',
                        subtitle: 'Ports & disponibilité',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TidesScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.cloud_rounded,
                        iconBg: const Color(0xFFE0F2FE),
                        iconColor: const Color(0xFF0284C7),
                        title: 'Météo marine',
                        subtitle: 'Vent & état de la mer',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WeatherScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.explore_rounded,
                        iconBg: const Color(0xFFDDF7FA),
                        iconColor: const Color(0xFF008DA7),
                        title: 'Rose des vents',
                        subtitle: 'Règle Cras & Boussole',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CompassScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.checklist_rounded,
                        iconBg: const Color(0xFFFFE6DB),
                        iconColor: const Color(0xFFFF7043),
                        title: 'Check-lists',
                        subtitle: 'Sécurité & matériel',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChecklistScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.radio_rounded,
                        iconBg: const Color(0xFFDDF7FA),
                        iconColor: const Color(0xFF008DA7),
                        title: 'Canaux VHF',
                        subtitle: 'Fréquences & secours',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VhfScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.rule_rounded,
                        iconBg: const Color(0xFFE7EDF0),
                        iconColor: const Color(0xFF527985),
                        title: 'Règles & balisage',
                        subtitle: 'RIPA, feux, cardinales',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RulesScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.menu_book_rounded,
                        iconBg: const Color(0xFFFFF0C2),
                        iconColor: const Color(0xFFE6A000),
                        title: 'Journal de bord',
                        subtitle: 'Traces & notes',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LogbookScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.map_rounded,
                        iconBg: const Color(0xFFDDF7FA),
                        iconColor: const Color(0xFF008DA7),
                        title: 'Cartes',
                        subtitle: 'Navigation & repères',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MarineMapScreen(),
                            ),
                          );
                        },
                      ),
                      _GridCard(
                        icon: Icons.info_outline_rounded,
                        iconBg: const Color(0xFFE7EDF0),
                        iconColor: const Color(0xFF527985),
                        title: 'À propos',
                        subtitle: 'KipMarine & version',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _GridCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final tileSurface = isDark ? const Color(0xFF082B38) : Colors.white;
    final accent = isDark ? Color.lerp(iconColor, Colors.white, .16)! : iconColor;

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: tileSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? accent.withValues(alpha: .30)
                    : iconColor.withValues(alpha: .13),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color.lerp(tileSurface, iconColor, .17)!,
                        const Color(0xFF061C27),
                      ]
                    : [
                        Colors.white,
                        Color.lerp(Colors.white, iconBg, .72)!,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : iconColor).withValues(
                    alpha: isDark ? .20 : .10,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Stack(
                children: [
                  Positioned(
                    right: -24,
                    top: -28,
                    child: Container(
                      width: 98,
                      height: 98,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor.withValues(alpha: isDark ? .08 : .07),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant.withValues(alpha: .50),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                isDark
                                    ? iconColor.withValues(alpha: .32)
                                    : iconBg,
                                isDark
                                    ? iconColor.withValues(alpha: .12)
                                    : Color.lerp(iconBg, Colors.white, .32)!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: iconColor.withValues(alpha: .18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: iconColor.withValues(alpha: .11),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: accent, size: 24),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: -.25,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10.5,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
