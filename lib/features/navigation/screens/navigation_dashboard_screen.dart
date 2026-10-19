
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/marine_formatter.dart';
import '../providers/navigation_provider.dart';
import '../../mob/providers/mob_provider.dart';
import '../../mob/screens/mob_screen.dart';
import '../../compass/screens/compass_screen.dart';
import '../../vhf/screens/vhf_screen.dart';
import '../../checklists/screens/checklist_screen.dart';
import '../../rules/screens/rules_screen.dart';
import '../../tides/screens/tides_screen.dart';
import '../../about/screens/about_screen.dart';
import '../../settings/screens/settings_screen.dart';

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
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête : titre, date et actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KipMarine',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _getFormattedDate(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
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

                  const SizedBox(height: 20),

                  // Carte vitesse SOG, COG et position GPS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryTeal,
                          AppColors.primaryTealDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
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
                        Positioned(
                          right: -10,
                          top: -10,
                          child: Icon(
                            Icons.explore_outlined,
                            size: 130,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        Column(
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
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: navProvider.isTracking
                                        ? AppColors.okGreen
                                        : Colors.orange,
                                    shape: BoxShape.circle,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Grille des modules
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.35,
                    children: [
                      const _GridCard(
                        icon: Icons.anchor,
                        iconBg: AppColors.iconBgCyan,
                        iconColor: AppColors.primaryTeal,
                        title: 'Mouillage',
                        subtitle: 'Alarme d’évitage',
                      ),
                      _GridCard(
                        icon: Icons.waves,
                        iconBg: AppColors.iconBgCyan,
                        iconColor: AppColors.primaryTeal,
                        title: 'Marées',
                        subtitle: 'Hauteurs & étales',
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
                        icon: Icons.explore_outlined,
                        iconBg: AppColors.iconBgCyan,
                        iconColor: AppColors.primaryTeal,
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
                        icon: Icons.assignment_turned_in_rounded,
                        iconBg: AppColors.iconBgRed,
                        iconColor: AppColors.mobOrange,
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
                        icon: Icons.settings_input_antenna_rounded,
                        iconBg: AppColors.iconBgCyan,
                        iconColor: AppColors.primaryTeal,
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
                        icon: Icons.menu_book_outlined,
                        iconBg: AppColors.iconBgCyan,
                        iconColor: AppColors.primaryTeal,
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
                        icon: Icons.info_outline_rounded,
                        iconBg: AppColors.iconBgCyan,
                        iconColor: AppColors.primaryTeal,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)
                    : iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
