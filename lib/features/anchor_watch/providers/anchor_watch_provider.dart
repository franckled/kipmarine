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
  double _targetRadiusMeters = 35.0;

  AnchorConfig? get config => _config;
  double get targetRadiusMeters => _targetRadiusMeters;
  bool get isAlarmTriggered => _config?.isAlarmTriggered ?? false;

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

  /// Demande la permission des notifications au moment où l'utilisateur
  /// active volontairement la surveillance du mouillage.
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
    notifyListeners();
  }

  /// Lève l'ancre et désactive la surveillance.
  Future<void> raiseAnchor() async {
    await _alarmService.stopAlarm();
    _config = null;
    notifyListeners();
  }

  /// Calcule la dérive uniquement à partir de positions GPS récentes et valides.
  void updatePosition(NavigationData currentPosition) {
    final config = _config;
    if (config == null || !config.isActive || !currentPosition.hasFreshPosition) {
      return;
    }

    final distance = MarineUnits.haversineDistance(
      config.anchorLatitude,
      config.anchorLongitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );
    if (!distance.isFinite || distance < 0) return;

    final isOut = distance > config.radiusMeters;
    final wasAlreadyOut = config.isAlarmTriggered;

    // Évite des notifications et reconstructions répétitives pour un point
    // GPS inchangé, sans masquer une transition dans/hors du cercle.
    if ((distance - config.currentDistance).abs() < 0.5 &&
        isOut == wasAlreadyOut) {
      return;
    }

    _config = config.copyWith(
      currentDistance: distance,
      isAlarmTriggered: isOut,
    );

    if (isOut && !wasAlreadyOut) {
      _alarmService.triggerAlarm();
    } else if (!isOut && _alarmService.isPlaying) {
      _alarmService.stopAlarm();
    }

    notifyListeners();
  }

  /// Coupe l'alarme manuellement.
  Future<void> silenceAlarm() async {
    await _alarmService.stopAlarm();
    notifyListeners();
  }

  @override
  void dispose() {
    _navigationProvider?.removeListener(_onNavigationChanged);
    _alarmService.stopAlarm();
    super.dispose();
  }
}
