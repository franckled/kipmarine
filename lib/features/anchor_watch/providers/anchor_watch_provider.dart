import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../../core/constants/marine_units.dart';
import '../../../core/services/alarm_service.dart';
import '../../navigation/models/navigation_data.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../models/anchor_config.dart';

class AnchorWatchProvider extends ChangeNotifier {
  final AlarmService _alarmService = AlarmService();

  AnchorConfig? _config;
  NavigationProvider? _navigationProvider;
  Timer? _gpsFreshnessTimer;
  double _targetRadiusMeters = 35.0;
  bool _gpsLost = false;

  AnchorConfig? get config => _config;
  double get targetRadiusMeters => _targetRadiusMeters;
  bool get isAlarmTriggered => _config?.isAlarmTriggered ?? false;
  bool get isGpsLost => _config?.isActive == true && _gpsLost;

  /// Se branche directement sur le flux de navigation, indépendamment de l'écran
  /// affiché. Le suivi ne dépend donc plus de la reconstruction de l'écran.
  void bindNavigationProvider(NavigationProvider navigationProvider) {
    if (identical(_navigationProvider, navigationProvider)) return;
    _navigationProvider?.removeListener(_onNavigationChanged);
    _navigationProvider = navigationProvider;
    _navigationProvider!.addListener(_onNavigationChanged);
    _onNavigationChanged();
  }

  void _onNavigationChanged() {
    final position = _navigationProvider?.currentData;
    if (position != null) updatePosition(position);
  }

  /// Détecte également l'absence de nouveaux relevés GPS. Ce timer améliore
  /// l'alerte lorsque l'isolate est actif ; le système peut toutefois suspendre
  /// les timers en arrière-plan, d'où la nécessité des permissions GPS adaptées.
  void _startGpsFreshnessMonitor() {
    _gpsFreshnessTimer?.cancel();
    _gpsFreshnessTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        final config = _config;
        if (config == null || !config.isActive) return;
        final position = _navigationProvider?.currentData;
        if (position == null || !position.hasFreshPosition) {
          _markGpsLost();
        }
      },
    );
  }

  void _markGpsLost() {
    if (_config?.isActive != true || _gpsLost) return;
    _gpsLost = true;
    unawaited(_alarmService.triggerAlarm());
    notifyListeners();
  }

  /// Demande la permission des notifications quand l'utilisateur active
  /// volontairement la surveillance du mouillage.
  Future<bool> prepareForMonitoring() => _alarmService.prepareForMonitoring();

  /// Modifie la consigne du rayon de sécurité.
  void setTargetRadius(double radius) {
    if (!radius.isFinite || radius < 10 || radius > 150) return;
    _targetRadiusMeters = radius;
    if (_config != null && _config!.isActive) {
      _config = _config!.copyWith(radiusMeters: radius);
    }
    notifyListeners();
  }

  /// Mouille l'ancre uniquement à partir d'une position GPS récente et valide.
  void dropAnchor(NavigationData currentPosition) {
    if (!currentPosition.hasFreshPosition) return;
    _config = AnchorConfig(
      anchorLatitude: currentPosition.latitude,
      anchorLongitude: currentPosition.longitude,
      radiusMeters: _targetRadiusMeters,
      isActive: true,
      currentDistance: 0.0,
      isAlarmTriggered: false,
    );
    _gpsLost = false;
    _startGpsFreshnessMonitor();
    notifyListeners();
  }

  /// Lève l'ancre et désactive la surveillance.
  Future<void> raiseAnchor() async {
    _gpsFreshnessTimer?.cancel();
    _gpsFreshnessTimer = null;
    _gpsLost = false;
    await _alarmService.stopAlarm();
    _config = null;
    notifyListeners();
  }

  /// Calcule la dérive uniquement à partir de positions GPS récentes et valides.
  void updatePosition(NavigationData currentPosition) {
    final config = _config;
    if (config == null || !config.isActive) return;
    if (!currentPosition.hasFreshPosition) {
      _markGpsLost();
      return;
    }

    final gpsWasLost = _gpsLost;
    _gpsLost = false;

    final distance = MarineUnits.haversineDistance(
      config.anchorLatitude,
      config.anchorLongitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );
    if (!distance.isFinite || distance < 0) {
      _markGpsLost();
      return;
    }

    final isOut = distance > config.radiusMeters;
    final wasAlreadyOut = config.isAlarmTriggered;

    // Si le bateau est revenu dans le cercle, l'alarme peut être acquittée.
    if (!isOut && _alarmService.isPlaying) {
      unawaited(_alarmService.stopAlarm());
    } else if (isOut && !wasAlreadyOut) {
      unawaited(_alarmService.triggerAlarm());
    }

    // Une récupération GPS doit rafraîchir l'écran même si la distance n'a
    // presque pas changé depuis le dernier relevé valide.
    if ((distance - config.currentDistance).abs() < 0.5 &&
        isOut == wasAlreadyOut &&
        !gpsWasLost) {
      return;
    }

    _config = config.copyWith(
      currentDistance: distance,
      isAlarmTriggered: isOut,
    );
    notifyListeners();
  }

  /// Coupe l'alarme manuellement.
  Future<void> silenceAlarm() async {
    await _alarmService.stopAlarm();
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsFreshnessTimer?.cancel();
    _navigationProvider?.removeListener(_onNavigationChanged);
    unawaited(_alarmService.stopAlarm());
    super.dispose();
  }
}
