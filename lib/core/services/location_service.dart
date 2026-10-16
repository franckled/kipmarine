import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../features/navigation/models/navigation_data.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Vérifie et demande les permissions GPS nécessaires
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Les services de localisation sont désactivés sur l'appareil
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Les permissions sont refusées de façon permanente
      return false;
    }

    return true;
  }

  /// Obtient la position GPS actuelle ponctuelle
  Future<NavigationData?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return NavigationData.fromPosition(position);
    } catch (e) {
      return null;
    }
  }

  /// Fournit un flux continu de positions GPS pour la navigation
  Stream<NavigationData> getNavigationStream({
    int distanceFilterMeters = 2, // Mise à jour tous les 2 mètres de déplacement
  }) {
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
      forceLocationManager: false,
      intervalDuration: const Duration(seconds: 1), // Rafraîchissement 1s
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "KipMarine suit votre position et votre vitesse en mer.",
        notificationTitle: "Navigation KipMarine Active",
        enableWakeLock: true,
      ),
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((position) => NavigationData.fromPosition(position));
  }

  /// Arrête le suivi GPS
  void dispose() {
    _positionStreamSubscription?.cancel();
  }
}
