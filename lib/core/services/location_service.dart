import 'dart:async';
import 'dart:io';

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
      if (!await checkAndRequestPermissions()) return null;
      final position = await Geolocator.getLastKnownPosition();
      if (position == null || position.accuracy <= 0) return null;
      return NavigationData.fromPosition(position);
    } catch (_) {
      return null;
    }
  }

  /// Obtient une nouvelle position GPS.
  Future<NavigationData?> getCurrentPosition() async {
    if (!await checkAndRequestPermissions()) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return NavigationData.fromPosition(position);
    } catch (_) {
      // Une position mémorisée peut être ancienne : l'interface doit afficher
      // son horodatage et ne pas la présenter comme une mesure en temps réel.
      return getLastKnownPosition();
    }
  }

  /// Flux GPS pour la navigation. iOS et Android nécessitent des réglages
  /// différents, en particulier pour le suivi lorsque l'application passe
  /// en arrière-plan.
  Stream<NavigationData> getNavigationStream({
    int distanceFilterMeters = 2,
  }) {
    final distanceFilter = distanceFilterMeters < 0 ? 0 : distanceFilterMeters;
    late final LocationSettings settings;

    if (Platform.isIOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.otherNavigation,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else if (Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilter,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'KipMarine — surveillance GPS active',
          notificationText:
              'Le GPS reste actif pour la navigation et l’alarme de mouillage.',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else {
      settings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilter,
      );
    }

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
