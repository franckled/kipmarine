import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/marine_units.dart';
import '../../../core/services/alarm_service.dart';
import '../../../core/services/anchor_notification_service.dart';
import '../../navigation/models/navigation_data.dart';
import '../models/anchor_config.dart';

class AnchorWatchProvider extends ChangeNotifier {
  static const _storageKey = 'kipmarine_anchor_watch_config';

  final AlarmService _alarmService = AlarmService();

  AnchorConfig? _config;
  double _targetRadiusMeters = 35.0;
  bool _alarmSilencedUntilSafe = false;
  bool _isLoading = true;
  bool _isSoundTestActive = false;

  AnchorConfig? get config => _config;
  double get targetRadiusMeters => _targetRadiusMeters;
  bool get isAlarmTriggered => _config?.isAlarmTriggered ?? false;
  bool get isAlarmSilenced => _alarmSilencedUntilSafe;
  bool get isLoading => _isLoading;
  bool get isSoundTestActive => _isSoundTestActive;
  bool get isAlarmSoundPlaying => _alarmService.isAudioActive;
  String? get alarmSoundError => _alarmService.lastAudioError;

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
    _alarmSilencedUntilSafe = false;
    unawaited(AnchorNotificationService.instance.initialize());
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
    // Avoid rebuild loops when the screen rechecks an unchanged GPS fix.
    if (wasOut == isOut && (distance - config.currentDistance).abs() < 0.5) {
      return;
    }
    _config = config.copyWith(
      currentDistance: distance,
      isAlarmTriggered: isOut,
    );

    if (isOut) {
      // Show a lock-screen notification on the transition into a drift alert.
      if (!wasOut) {
        unawaited(AnchorNotificationService.instance.showAnchorDriftAlert());
      }
      // Un acquittement reste valable jusqu'au retour dans le cercle.
      if (!_alarmSilencedUntilSafe &&
          (!wasOut || !_alarmService.isAudioActive)) {
        unawaited(_alarmService.triggerAlarm());
      }
    } else {
      _alarmSilencedUntilSafe = false;
      if (wasOut) {
        unawaited(AnchorNotificationService.instance.clearAnchorDriftAlert());
      }
      if (_alarmService.isPlaying) {
        unawaited(_alarmService.stopAlarm());
      }
    }

    // Écrit seulement lors d'un changement d'état, pas à chaque point GPS.
    if (wasOut != isOut) unawaited(_persistConfig());
    notifyListeners();
  }

  /// Lance une alerte sonore manuelle pour tester le haut-parleur du téléphone.
  Future<void> testAlarmSound() async {
    await _alarmService.stopAlarm();
    _isSoundTestActive = true;
    notifyListeners();
    await _alarmService.triggerAlarm();
  }

  /// Relance explicitement le son lorsqu'une dérive est déjà signalée.
  Future<void> retriggerAlarmSound() async {
    _alarmSilencedUntilSafe = false;
    await _alarmService.stopAlarm();
    _isSoundTestActive = false;
    await _alarmService.triggerAlarm();
    notifyListeners();
  }

  /// Arrête le test sonore sans acquitter une éventuelle vraie dérive.
  Future<void> stopAlarmSoundTest() async {
    _isSoundTestActive = false;
    await _alarmService.stopAlarm();
    notifyListeners();
  }

  /// Coupe l'alarme jusqu'au retour dans le rayon de sécurité.
  Future<void> silenceAlarm() async {
    _alarmSilencedUntilSafe = true;
    _isSoundTestActive = false;
    await _alarmService.stopAlarm();
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_alarmService.dispose());
    super.dispose();
  }
}
