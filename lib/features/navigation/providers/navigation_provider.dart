import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/location_service.dart';
import '../models/navigation_data.dart';

class NavigationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  NavigationData? _currentData;
  StreamSubscription<NavigationData>? _positionSubscription;
  bool _isTracking = false;
  bool _hasPermission = true;
  String? _errorMessage;

  // Getters pour l'UI
  NavigationData? get currentData => _currentData;
  bool get isTracking => _isTracking;
  bool get hasPermission => _hasPermission;
  String? get errorMessage => _errorMessage;

  /// Démarre l'écoute du flux GPS temps réel
  Future<void> startTracking() async {
    if (_isTracking) return;

    final permissionOk = await _locationService.checkAndRequestPermissions();
    if (!permissionOk) {
      _hasPermission = false;
      _errorMessage = "Signal GPS indisponible ou permission refusée.";
      notifyListeners();
      return;
    }

    _hasPermission = true;
    _errorMessage = null;
    _isTracking = true;
    notifyListeners();

    _positionSubscription = _locationService.getNavigationStream().listen(
      (data) {
        _currentData = data;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = "Erreur de réception GPS : $error";
        notifyListeners();
      },
    );
  }

  /// Arrête le suivi GPS
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    _locationService.dispose();
    super.dispose();
  }
}
