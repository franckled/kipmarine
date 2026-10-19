import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../features/navigation/models/navigation_data.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Vérifie et demande les permissions GPS nécessaires.
  Future<bool> checkAndRequestPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  /// Obtient une position GPS ponctuelle.
  Future<NavigationData?> getCurrentPosition() async {
    if (!await checkAndRequestPermissions()) return null;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return NavigationData.fromPosition(position);
    } catch (_) {
      return null;
    }
  }

  /// Flux GPS configuré explicitement selon la plateforme.
  Stream<NavigationData> getNavigationStream({int distanceFilterMeters = 2}) {
    late final LocationSettings settings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: 'KipMarine suit votre position et votre vitesse en mer.',
          notificationTitle: 'Navigation KipMarine active',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilterMeters,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      );
    }

    return Geolocator.getPositionStream(locationSettings: settings)
        .map(NavigationData.fromPosition);
  }

  void dispose() {
    _positionStreamSubscription?.cancel();
  }
}
