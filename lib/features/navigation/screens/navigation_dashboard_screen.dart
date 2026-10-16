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

  String _getFormattedDate() {
    final now = DateTime.now();
    final days = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
    final months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${days[now.weekday - 1]} ${now.day}${months[now.month - 1]}';
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
                              fontWeight: FontWeight.w900,
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
                                fontWeight: FontWeight.w900,
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
                                    content: Text('Attente du signal GPS pour le point MOB...'),
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

                  // Carte Vitesse SOG / COG / Position
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
