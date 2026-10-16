import 'dart:math';
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

    // Position du bateau (ou position par défaut si le GPS charge)
    final LatLng boatLatLng = currentPosition != null
        ? LatLng(currentPosition.latitude, currentPosition.longitude)
        : const LatLng(42.7000, 9.4500);

    // Déplacement automatique de la carte si le mode suivi est actif
    if (_followBoat && currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(boatLatLng, _mapController.camera.zoom);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CARTE MARINE', style: TextStyle(fontWeight: FontWeight.bold)),
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
              initialZoom: 14.0,
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
                urlTemplate: 'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kipmarine.app',
              ),

              // Cercle de sécurité du mouillage
              if (anchorConfig != null && anchorConfig.isActive)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(anchorConfig.anchorLatitude, anchorConfig.anchorLongitude),
                      radius: anchorConfig.radiusMeters,
                      useRadiusInMeter: true,
                      color: anchorProvider.isAlarmTriggered
                          ? AppColors.alertRed.withOpacity(0.3)
                          : AppColors.okGreen.withOpacity(0.2),
                      borderColor: anchorProvider.isAlarmTriggered ? AppColors.alertRed : AppColors.okGreen,
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
                      point: LatLng(anchorConfig.anchorLatitude, anchorConfig.anchorLongitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.anchor, color: AppColors.accent, size: 24),
                      ),
                    ),

                  // Marqueur du Bateau (orienté selon le COG)
                  if (currentPosition != null)
                    Marker(
                      point: boatLatLng,
                      width: 50,
                      height: 50,
                      child: Transform.rotate(
                        angle: (currentPosition.heading * pi / 180),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 6),
                            ],
                          ),
                          child: const Icon(
                            Icons.navigation_rounded,
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
