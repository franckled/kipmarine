import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/location_service.dart';
import '../models/navigation_data.dart';

class NavigationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  NavigationData? _currentData;
  StreamSubscription<NavigationData>? _positionSubscription;
  bool _isTracking = false;
  bool _isStarting = false;
  bool _isDisposed = false;
  bool _hasPermission = true;
  String? _errorMessage;

  // Getters pour l'UI
  NavigationData? get currentData => _currentData;
  bool get isTracking => _isTracking;
  bool get hasPermission => _hasPermission;
  String? get errorMessage => _errorMessage;

  /// Indique si la surveillance du mouillage peut continuer en arrière-plan.
  Future<bool> hasBackgroundLocationPermission() =>
      _locationService.hasBackgroundLocationPermission();

  /// Démarre l'écoute du flux GPS temps réel.
  Future<void> startTracking() async {
    if (_isTracking || _isStarting || _isDisposed) return;
    _isStarting = true;

    try {
      final permissionOk =
          await _locationService.checkAndRequestPermissions();
      if (_isDisposed) return;

      if (!permissionOk) {
        _hasPermission = false;
        _errorMessage = 'Signal GPS indisponible ou permission refusée.';
        notifyListeners();
        return;
      }

      _hasPermission = true;
      _errorMessage = null;
      _isTracking = true;
      notifyListeners();

      _positionSubscription = _locationService.getNavigationStream().listen(
        (data) {
          if (_isDisposed) return;
          _currentData = data;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (Object error) {
          if (_isDisposed) return;
          _errorMessage = 'Erreur de réception GPS : $error';
          notifyListeners();
        },
        onDone: () {
          if (_isDisposed) return;
          _isTracking = false;
          notifyListeners();
        },
      );
    } catch (error) {
      if (_isDisposed) return;
      _isTracking = false;
      _errorMessage = 'Impossible de démarrer le GPS : $error';
      notifyListeners();
    } finally {
      _isStarting = false;
    }
  }

  /// Arrête le suivi GPS.
  Future<void> stopTracking() async {
    final subscription = _positionSubscription;
    _positionSubscription = null;
    await subscription?.cancel();

    if (_isDisposed) return;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isTracking = false;
    final subscription = _positionSubscription;
    _positionSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    _locationService.dispose();
    super.dispose();
  }
}
