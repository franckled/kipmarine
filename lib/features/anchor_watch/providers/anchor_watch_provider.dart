import 'package:flutter/foundation.dart';
import '../../../core/constants/marine_units.dart';
import '../../../core/services/alarm_service.dart';
import '../../navigation/models/navigation_data.dart';
import '../models/anchor_config.dart';

class AnchorWatchProvider extends ChangeNotifier {
  final AlarmService _alarmService = AlarmService();

  AnchorConfig? _config;
  double _targetRadiusMeters = 35.0; // Rayon par défaut
  bool _alarmSilencedUntilSafe = false;

  AnchorConfig? get config => _config;
  double get targetRadiusMeters => _targetRadiusMeters;
  bool get isAlarmTriggered => _config?.isAlarmTriggered ?? false;

  /// Modifie la consigne du rayon de sécurité
  void setTargetRadius(double radius) {
    _targetRadiusMeters = radius;
    if (_config != null && _config!.isActive) {
      _config = _config!.copyWith(radiusMeters: radius);
    }
    notifyListeners();
  }

  /// Mouille l'ancre à la position actuelle
  void dropAnchor(NavigationData currentPosition) {
    _alarmSilencedUntilSafe = false;
    _config = AnchorConfig(
      anchorLatitude: currentPosition.latitude,
      anchorLongitude: currentPosition.longitude,
      radiusMeters: _targetRadiusMeters,
      isActive: true,
      currentDistance: 0.0,
      isAlarmTriggered: false,
    );
    notifyListeners();
  }

  /// Lève l'ancre et désactive la surveillance
  Future<void> raiseAnchor() async {
    await _alarmService.stopAlarm();
    _config = null;
    notifyListeners();
  }

  /// Reçoit la position GPS mise à jour et calcule la dérive
  void updatePosition(NavigationData currentPosition) {
    if (_config == null || !_config!.isActive) return;

    final distance = MarineUnits.haversineDistance(
      _config!.anchorLatitude,
      _config!.anchorLongitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    final isOut = distance > _config!.radiusMeters;
    final wasOut = _config!.isAlarmTriggered;

    _config = _config!.copyWith(
      currentDistance: distance,
      isAlarmTriggered: isOut,
    );

    if (isOut) {
      // Une alarme acquittée reste silencieuse tant que le bateau ne
      // revient pas dans le cercle de sécurité. Cela évite de la relancer
      // à chaque nouvelle position GPS.
      if (!_alarmSilencedUntilSafe && !wasOut) {
        _alarmService.triggerAlarm();
      } else if (!_alarmSilencedUntilSafe && !_alarmService.isPlaying) {
        _alarmService.triggerAlarm();
      }
    } else {
      _alarmSilencedUntilSafe = false;
      if (_alarmService.isPlaying) {
        _alarmService.stopAlarm();
      }
    }

    notifyListeners();
  }

  /// Coupe l'alarme manuellement
  Future<void> silenceAlarm() async {
    // L'acquittement est valable jusqu'au retour dans le rayon de sécurité.
    _alarmSilencedUntilSafe = true;
    await _alarmService.stopAlarm();
    notifyListeners();
  }

  @override
  void dispose() {
    _alarmService.stopAlarm();
    super.dispose();
  }
}
