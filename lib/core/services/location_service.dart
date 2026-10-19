import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../features/navigation/models/navigation_data.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Vérifie et demande les permissions GPS nécessaires.
  Future<bool> checkAndRequestPermissions() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return false;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// Récupère rapidement une position connue, si disponible.
  Future<NavigationData?> getLastKnownPosition() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) return null;

      final position = await Geolocator.getLastKnownPosition();

      if (position == null || position.accuracy <= 0) {
        return null;
      }

      return NavigationData.fromPosition(position);
    } catch (_) {
      return null;
    }
  }

  /// Obtient une nouvelle position GPS.
  Future<NavigationData?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return NavigationData.fromPosition(position);
    } catch (_) {
      // La position précédente peut être utilisée en attendant
      // une nouvelle mesure, mais elle peut être ancienne.
      return getLastKnownPosition();
    }
  }

  /// Flux continu de positions pour la navigation.
  Stream<NavigationData> getNavigationStream({
    int distanceFilterMeters = 2,
  }) {
    const settings = AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      activityType: ActivityType.otherNavigation,
      distanceFilter: 2,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
    );

    return Geolocator.getPositionStream(
      locationSettings: settings,
    ).map(NavigationData.fromPosition);
  }

  /// Arrête le suivi GPS.
  Future<void> dispose() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
}
