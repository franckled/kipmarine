import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../anchor_watch/providers/anchor_watch_provider.dart';
import '../../navigation/providers/navigation_provider.dart';

class MarineMapScreen extends StatefulWidget {
  const MarineMapScreen({super.key});

  @override
  State<MarineMapScreen> createState() => _MarineMapScreenState();
}

class _MarineMapScreenState extends State<MarineMapScreen> {
  final MapController _mapController = MapController();
  bool _followBoat = true;

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final anchorProvider = context.watch<AnchorWatchProvider>();
    final currentPosition = navProvider.currentData;
    final anchorConfig = anchorProvider.config;

    // La position réelle n'est affichée qu'après réception d'un relevé GPS.
    // En attente, afficher une vue mondiale neutre plutôt qu'une fausse position en Corse.
    final hasGpsPosition = currentPosition != null;
    final LatLng boatLatLng = hasGpsPosition
        ? LatLng(currentPosition.latitude, currentPosition.longitude)
        : const LatLng(20.0, 0.0);

    // Déplacement automatique de la carte si le mode suivi est actif
    if (_followBoat && currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(boatLatLng, _mapController.camera.zoom);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CARTE MARINE',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _followBoat ? Icons.my_location : Icons.location_searching,
              color: _followBoat ? AppColors.accent : Colors.white60,
            ),
            onPressed: () {
              setState(() {
                _followBoat = !_followBoat;
                if (_followBoat && currentPosition != null) {
                  _mapController.move(boatLatLng, 15.0);
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: boatLatLng,
              initialZoom: hasGpsPosition ? 14.0 : 2.5,
              minZoom: 3.0,
              maxZoom: 18.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture && _followBoat) {
                  // Désactive le suivi automatique si l'utilisateur déplace la carte manuellement
                  setState(() {
                    _followBoat = false;
                  });
                }
              },
            ),
            children: [
              // Couche de fond OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kipmarine.app',
              ),
              // Couche de balisage maritime OpenSeaMap
              TileLayer(
                urlTemplate:
                    'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kipmarine.app',
              ),

              // Cercle de sécurité du mouillage
              if (anchorConfig != null && anchorConfig.isActive)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(anchorConfig.anchorLatitude,
                          anchorConfig.anchorLongitude),
                      radius: anchorConfig.radiusMeters,
                      useRadiusInMeter: true,
                      color: anchorProvider.isAlarmTriggered
                          ? AppColors.alertRed.withOpacity(0.3)
                          : AppColors.okGreen.withOpacity(0.2),
                      borderColor: anchorProvider.isAlarmTriggered
                          ? AppColors.alertRed
                          : AppColors.okGreen,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),

              // Marqueurs : Ancre et Bateau
              MarkerLayer(
                markers: [
                  // Marqueur de l'Ancre
                  if (anchorConfig != null && anchorConfig.isActive)
                    Marker(
                      point: LatLng(anchorConfig.anchorLatitude,
                          anchorConfig.anchorLongitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.anchor,
                            color: AppColors.accent, size: 24),
                      ),
                    ),

                  // Marqueur du Bateau (orienté selon le COG)
                  if (currentPosition != null)
                    Marker(
                      point: boatLatLng,
                      width: 50,
                      height: 50,
                      child: Transform.rotate(
                        angle: currentPosition.hasValidCourse
                            ? currentPosition.heading * pi / 180
                            : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 6),
                            ],
                          ),
                          child: Icon(
                            currentPosition.hasValidCourse
                                ? Icons.navigation_rounded
                                : Icons.my_location,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (!hasGpsPosition)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: AppColors.primaryDark,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.gps_not_fixed, color: AppColors.accent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'En attente du GPS : la carte affiche une vue mondiale, pas la position du bateau.',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bouton flottant de recentrage rapide sur le bateau
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: AppColors.primaryDark,
              child: const Icon(Icons.gps_fixed, color: AppColors.accent),
              onPressed: () {
                setState(() {
                  _followBoat = true;
                });
                if (currentPosition != null) {
                  _mapController.move(boatLatLng, 15.0);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
