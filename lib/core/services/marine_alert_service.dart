import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local alerts are delivered by iOS/Android even when Flutter is not visible,
/// provided the operating system has not force-quit the app and permissions are enabled.
class MarineAlertService {
  MarineAlertService._();

  static final MarineAlertService instance = MarineAlertService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    try {
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (error) {
      debugPrint('KipMarine notifications initialization failed: $error');
    }
  }

  Future<bool> requestPermissions() async {
    await initialize();
    try {
      final ios = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      final mac = await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      final android = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return ios ?? mac ?? android ?? true;
    } catch (error) {
      debugPrint('KipMarine notification permission request failed: $error');
      return false;
    }
  }

  Future<void> showAnchorDrift() async {
    await _show(
      id: 7101,
      title: 'KipMarine — DÉRIVE DE MOUILLAGE',
      body: 'Le bateau a dépassé le cercle de sécurité. Vérifiez immédiatement la position.',
    );
  }

  Future<void> showMob() async {
    await _show(
      id: 7102,
      title: 'KipMarine — HOMME À LA MER',
      body: 'Alerte MOB déclenchée. Rejoignez la position enregistrée et lancez les procédures de secours.',
    );
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'kipmarine_emergency_alerts',
        'Alertes de sécurité maritime',
        channelDescription: 'Alertes de dérive et homme à la mer',
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
      await _plugin.show(id, title, body, details);
      // Keep a safety alert audible at intervals if the app is backgrounded
      // or the screen is locked. The repeated request is cancelled on recovery
      // or explicit acknowledgement.
      await _plugin.periodicallyShow(
        id + 100,
        title,
        body,
        RepeatInterval.everyMinute,
        details,
      );
    } catch (error) {
      debugPrint('KipMarine alert notification failed: $error');
    }
  }

  Future<void> clear(int id) async {
    try {
      await _plugin.cancel(id);
      await _plugin.cancel(id + 100);
    } catch (_) {}
  }
}
