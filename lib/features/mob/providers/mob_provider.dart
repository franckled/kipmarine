import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/constants/marine_units.dart';
import '../../navigation/models/navigation_data.dart';
import '../../../core/services/alarm_service.dart';

class MobProvider extends ChangeNotifier {
  NavigationData? _mobPosition;
  DateTime? _mobTimestamp;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isActive = false;
  final AlarmService _alarmService = AlarmService();

  NavigationData? get mobPosition => _mobPosition;
  DateTime? get mobTimestamp => _mobTimestamp;
  Duration get elapsedTime => _elapsedTime;
  bool get isActive => _isActive;

  /// Déclenche l'alerte Homme à la Mer à la position GPS actuelle
  void triggerMob(NavigationData currentData) {
    _mobPosition = currentData;
    _mobTimestamp = DateTime.now();
    _elapsedTime = Duration.zero;
    _isActive = true;
    _alarmService.triggerAlarm();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_mobTimestamp != null) {
        _elapsedTime = DateTime.now().difference(_mobTimestamp!);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// Calcule la distance en mètres entre le bateau et le point MOB
  double getDistanceToMob(NavigationData currentPosition) {
    if (_mobPosition == null) return 0.0;
    return MarineUnits.haversineDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      _mobPosition!.latitude,
      _mobPosition!.longitude,
    );
  }

  /// Calcule le cap (bearing) en degrés vers le point MOB
  double getBearingToMob(NavigationData currentPosition) {
    if (_mobPosition == null) return 0.0;
    final lat1 = currentPosition.latitude * pi / 180.0;
    final lon1 = currentPosition.longitude * pi / 180.0;
    final lat2 = _mobPosition!.latitude * pi / 180.0;
    final lon2 = _mobPosition!.longitude * pi / 180.0;

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final brng = atan2(y, x) * 180.0 / pi;

    return (brng + 360.0) % 360.0;
  }

  /// Convertit un cap en point cardinal (ex: SSE, NW)
  String getCardinal(double bearing) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((bearing + 11.25) % 360 / 22.5).floor();
    return directions[index];
  }

  /// Annule le point MOB
  void cancelMob() {
    _isActive = false;
    _mobPosition = null;
    _mobTimestamp = null;
    _timer?.cancel();
    _alarmService.stopAlarm();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _alarmService.stopAlarm();
    super.dispose();
  }
}
