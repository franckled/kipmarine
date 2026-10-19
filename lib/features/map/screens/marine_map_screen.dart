import 'dart:math' as math;
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

    // Position indicative de départ, uniquement en attendant le GPS.
    final LatLng boatLatLng = currentPosition != null
        ? LatLng(currentPosition.latitude, currentPosition.longitude)
        : const LatLng(42.7000, 9.4500);

    // N'utiliser le cap que s'il est déclaré valide.
    final double? cog = currentPosition != null &&
            currentPosition.hasValidCourse
        ? currentPosition.heading
        : null;

    if (_followBoat && currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_followBoat) return;
        try {
          _mapController.move(boatLatLng, _mapController.camera.zoom);
        } catch (_) {
          // La carte peut ne pas être encore initialisée.
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CARTE MARINE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _followBoat ? 'Désactiver le suivi' : 'Suivre le bateau',
            icon: Icon(
              _followBoat ? Icons.my_location : Icons.location_searching,
              color: _followBoat ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _followBoat = !_followBoat;
              });
              if (_followBoat && currentPosition != null) {
                _mapController.move(boatLatLng, 15.0);
              }
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
                if (hasGesture && _followBoat && mounted) {
                  setState(() {
                    _followBoat = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kipmarine.app',
              ),
              TileLayer(
                urlTemplate:
                    'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kipmarine.app',
              ),

              if (anchorConfig != null && anchorConfig.isActive)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(
                        anchorConfig.anchorLatitude,
                        anchorConfig.anchorLongitude,
                      ),
                      radius: anchorConfig.radiusMeters,
                      useRadiusInMeter: true,
                      color: anchorProvider.isAlarmTriggered
                          ? AppColors.alertRed.withValues(alpha: 0.3)
                          : AppColors.okGreen.withValues(alpha: 0.2),
                      borderColor: anchorProvider.isAlarmTriggered
                          ? AppColors.alertRed
                          : AppColors.okGreen,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  if (anchorConfig != null && anchorConfig.isActive)
                    Marker(
                      point: LatLng(
                        anchorConfig.anchorLatitude,
                        anchorConfig.anchorLongitude,
                      ),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.anchor,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ),

                  if (currentPosition != null)
                    Marker(
                      point: boatLatLng,
                      width: 54,
                      height: 54,
                      child: Transform.rotate(
                        // Pas de rotation artificielle si le COG est inconnu.
                        angle: cog == null ? 0.0 : cog * math.pi / 180,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cog == null
                                ? Colors.blueGrey
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            cog == null
                                ? Icons.location_on
                                : Icons.navigation_rounded,
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

          if (currentPosition == null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'En attente du GPS : la position affichée est indicative.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              tooltip: 'Recentrer sur le bateau',
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: () {
                setState(() {
                  _followBoat = true;
                });
                if (currentPosition != null) {
                  _mapController.move(boatLatLng, 15.0);
                }
              },
              child: Icon(
                Icons.gps_fixed,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
