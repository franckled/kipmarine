import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/marine_formatter.dart';
import '../providers/navigation_provider.dart';
import '../../mob/providers/mob_provider.dart';
import '../../mob/screens/mob_screen.dart';

class NavigationDashboardScreen extends StatefulWidget {
  const NavigationDashboardScreen({super.key});

  @override
  State<NavigationDashboardScreen> createState() => _NavigationDashboardScreenState();
}

class _NavigationDashboardScreenState extends State<NavigationDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<NavigationProvider>(
          builder: (context, navProvider, child) {
            final data = navProvider.currentData;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête : Titre + Date + Boutons d'action (Bateau + MOB)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KipMarine',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.black,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            _getFormattedDate(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Bouton Bateau
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.iconBgCyan,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_boat_filled_rounded,
                              color: AppColors.primaryTeal,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Bouton MOB (Homme à la mer) - Ouvre l'écran MOB
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mobOrange,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
                            label: const Text(
                              'MOB',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.black,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: () {
                              final navData = context.read<NavigationProvider>().currentData;
                              if (navData != null) {
                                context.read<MobProvider>().triggerMob(navData);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MobScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Attente du signal GPS pour enregistrer le point MOB...'),
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

                  // Hero Banner : Carte Vitesse SOG / COG / Position
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryTeal, AppColors.primaryTealDark],
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
                        // Filigrane Rose des Vents en fond
                        Positioned(
                          right: -10,
                          top: -10,
                          child: Icon(
                            Icons.explore_outlined,
                            size: 130,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'VITESSE GPS · SOG',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                // Indicateur signal GPS
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: navProvider.isTracking ? AppColors.okGreen : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossBaseline.alphabetic,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  data != null ? data.speedInKnots.toStringAsFixed(1) : '0.0',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.black,
                                    color: Colors.white,
                                    height: 1.0,
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
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data != null ? MarineFormatter.formatHeading(data.heading) : '---°',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'COG',
                                      style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  color: Colors.white24,
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'POSITION',
                                      style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      data != null ? MarineFormatter.formatLatitude(data.latitude) : '42°40.874\'N',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text(
                                      data != null ? MarineFormatter.formatLongitude(data.longitude) : '9°25.665\'E',
                                      style: const TextStyle(fontSize: 12, fontWeight:
