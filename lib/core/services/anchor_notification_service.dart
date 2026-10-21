import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notification for anchor-watch drift. Requires notification permission.
class AnchorNotificationService {
  AnchorNotificationService._();

  static final AnchorNotificationService instance =
      AnchorNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: false,
      ),
    );

    try {
      await _plugin.initialize(settings);
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, sound: true, badge: false);
      final macos = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      await macos?.requestPermissions(alert: true, sound: true, badge: false);
      _initialized = true;
    } catch (error) {
      debugPrint('KipMarine notification initialization failed: $error');
    }
  }

  Future<void> showAnchorDriftAlert() async {
    await initialize();
    if (!_initialized) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'anchor_drift_alerts',
        'Alertes de mouillage',
        channelDescription: 'Alertes lorsque le bateau sort du cercle de mouillage.',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    try {
      await _plugin.show(
        7101,
        'KipMarine — Dérive détectée',
        'Le bateau a dépassé le rayon de sécurité du mouillage. Vérifiez immédiatement votre position.',
        details,
      );
    } catch (error) {
      debugPrint('KipMarine anchor notification failed: $error');
    }
  }

  Future<void> clearAnchorDriftAlert() async {
    try {
      await _plugin.cancel(7101);
    } catch (error) {
      debugPrint('KipMarine anchor notification cancellation failed: $error');
    }
  }
}
