import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/marine_units.dart';
import '../../../core/services/alarm_service.dart';
import '../../../core/services/marine_alert_service.dart';
import '../../navigation/models/navigation_data.dart';
import '../models/anchor_config.dart';

class AnchorWatchProvider extends ChangeNotifier {
  static const _storageKey = 'kipmarine_anchor_watch_config';

  final AlarmService _alarmService = AlarmService();

  AnchorConfig? _config;
  double _targetRadiusMeters = 35.0;
  bool _alarmSilencedUntilSafe = false;
  bool _isLoading = true;

  AnchorConfig? get config => _config;
  double get targetRadiusMeters => _targetRadiusMeters;
  bool get isAlarmTriggered => _config?.isAlarmTriggered ?? false;
  bool get isLoading => _isLoading;

  AnchorWatchProvider() {
    _restoreConfig();
  }

  Future<void> _restoreConfig() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString(_storageKey);
      if (stored != null) {
        final decoded = jsonDecode(stored);
        if (decoded is Map<String, dynamic>) {
          final restored = AnchorConfig.fromJson(decoded);
          if (_config == null && restored.isActive) {
            _config = restored;
            _targetRadiusMeters = restored.radiusMeters;
          }
        }
      }
    } catch (_) {
      // Une configuration corrompue ne doit pas empêcher l'ouverture de l'app.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistConfig() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (_config == null || !_config!.isActive) {
        await preferences.remove(_storageKey);
      } else {
        await preferences.setString(_storageKey, jsonEncode(_config!.toJson()));
      }
    } catch (_) {
      // Le suivi reste utilisable en mémoire si le stockage échoue.
    }
  }

  /// Modifie le rayon de sécurité.
  void setTargetRadius(double radius) {
    if (!radius.isFinite || radius < 10 || radius > 150) return;
    _targetRadiusMeters = radius;
    if (_config != null && _config!.isActive) {
      _config = _config!.copyWith(radiusMeters: radius);
      unawaited(_persistConfig());
    }
    notifyListeners();
  }

  /// Enregistre la position actuelle comme point de mouillage.
  void dropAnchor(NavigationData currentPosition) {
    unawaited(MarineAlertService.instance.requestPermissions());
    _alarmSilencedUntilSafe = false;
    _config = AnchorConfig(
      anchorLatitude: currentPosition.latitude,
      anchorLongitude: currentPosition.longitude,
      radiusMeters: _targetRadiusMeters,
      isActive: true,
      currentDistance: 0,
      isAlarmTriggered: false,
    );
    unawaited(_persistConfig());
    notifyListeners();
  }

  /// Lève l'ancre et désactive la surveillance.
  Future<void> raiseAnchor() async {
    _alarmSilencedUntilSafe = false;
    await _alarmService.stopAlarm();
    await MarineAlertService.instance.clear(7101);
    _config = null;
    await _persistConfig();
    notifyListeners();
  }

  /// Met à jour la distance depuis le point de mouillage.
  void updatePosition(NavigationData currentPosition) {
    final config = _config;
    if (config == null || !config.isActive) return;

    final distance = MarineUnits.haversineDistance(
      config.anchorLatitude,
      config.anchorLongitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );
    if (!distance.isFinite) return;

    final isOut = distance > config.radiusMeters;
    final wasOut = config.isAlarmTriggered;
    _config = config.copyWith(
      currentDistance: distance,
      isAlarmTriggered: isOut,
    );

    if (isOut) {
      if (!wasOut) unawaited(MarineAlertService.instance.showAnchorDrift());
      // Un acquittement reste valable jusqu'au retour dans le cercle.
      if (!_alarmSilencedUntilSafe &&
          (!wasOut || !_alarmService.isPlaying)) {
        unawaited(_alarmService.triggerAlarm());
      }
    } else {
      _alarmSilencedUntilSafe = false;
      unawaited(MarineAlertService.instance.clear(7101));
      if (_alarmService.isPlaying) {
        unawaited(_alarmService.stopAlarm());
      }
    }

    // Écrit seulement lors d'un changement d'état, pas à chaque point GPS.
    if (wasOut != isOut) unawaited(_persistConfig());
    notifyListeners();
  }

  /// Coupe l'alarme jusqu'au retour dans le rayon de sécurité.
  Future<void> silenceAlarm() async {
    _alarmSilencedUntilSafe = true;
    await _alarmService.stopAlarm();
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_alarmService.dispose());
    super.dispose();
  }
}
