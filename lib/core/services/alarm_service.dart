import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class AlarmService {
  static const int _notificationId = 1872;
  static const String _channelId = 'kipmarine_anchor_alarm';

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isPlaying = false;
  bool _notificationsInitialized = false;

  bool get isPlaying => _isPlaying;

  /// Prépare les notifications au moment où l'utilisateur active le mouillage.
  /// La demande d'autorisation se fait ainsi en premier plan, pas au déclenchement.
  Future<bool> prepareForMonitoring() async {
    try {
      if (!_notificationsInitialized) {
        const initializationSettings = InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        );
        await _notifications.initialize(initializationSettings);
        _notificationsInitialized = true;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        return await ios?.requestPermissions(
              alert: true,
              badge: false,
              sound: true,
            ) ??
            false;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? true;
      }

      return true;
    } catch (_) {
      // La surveillance doit rester activable même si les notifications
      // ne sont pas disponibles : le son et la vibration restent tentés.
      return false;
    }
  }

  /// Déclenche le son, les vibrations et une notification système de secours.
  Future<void> triggerAlarm() async {
    if (_isPlaying) return;
    _isPlaying = true;

    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
      }
    } catch (_) {
      // L'absence de moteur de vibration ne doit pas empêcher les autres alertes.
    }

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/anchor_alarm.wav'));
    } catch (_) {
      // Le son local peut être indisponible en arrière-plan ; la notification
      // système constitue une seconde voie d'alerte.
    }

    try {
      if (!_notificationsInitialized) {
        const initializationSettings = InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        );
        await _notifications.initialize(initializationSettings);
        _notificationsInitialized = true;
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Alarme de mouillage',
          channelDescription: 'Alerte en cas de dérive du bateau au mouillage',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          ongoing: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        _notificationId,
        'KipMarine — dérive détectée',
        'Le bateau est sorti du cercle de sécurité du mouillage.',
        details,
      );
    } catch (_) {
      // Ne pas laisser une erreur de notification faire tomber le flux GPS.
    }
  }

  /// Arrête les alertes sonores, vibratoires et la notification persistante.
  Future<void> stopAlarm() async {
    _isPlaying = false;
    try {
      await Vibration.cancel();
    } catch (_) {
      // La vibration peut ne pas être prise en charge par la plateforme.
    }
    try {
      await _audioPlayer.stop();
    } catch (_) {
      // L'arrêt du lecteur ne doit pas empêcher l'annulation de la notification.
    }
    if (_notificationsInitialized) {
      try {
        await _notifications.cancel(_notificationId);
      } catch (_) {
        // L'alarme est déjà désarmée côté application.
      }
    }
  }
}
