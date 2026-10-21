import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Foreground audible/haptic alarm. Lock-screen alerts are issued separately
/// through MarineAlertService so the alert does not depend on this Dart timer.
class AlarmService {
  Timer? _soundTimer;
  bool _audioActive = false;
  bool _vibrationActive = false;
  bool _starting = false;
  bool _disposed = false;
  int _generation = 0;

  bool get isPlaying => _starting || _audioActive || _vibrationActive;

  Future<void> triggerAlarm() async {
    if (_disposed || isPlaying) return;
    final generation = ++_generation;
    _starting = true;

    // Start the audible loop immediately; this uses the native system alert
    // sound and does not rely on an asset file that may be absent from a build.
    _audioActive = true;
    unawaited(SystemSound.play(SystemSoundType.alert).catchError((_) {}));
    _soundTimer?.cancel();
    _soundTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_disposed && generation == _generation) {
        unawaited(SystemSound.play(SystemSoundType.alert).catchError((_) {}));
      }
    });

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (generation != _generation || _disposed) return;
      if (hasVibrator == true) {
        await Vibration.vibrate(pattern: [500, 500, 500, 1000], repeat: 0);
        if (generation == _generation && !_disposed) {
          _vibrationActive = true;
        }
      }
    } catch (_) {
      _vibrationActive = false;
    } finally {
      if (generation == _generation) _starting = false;
    }
  }

  Future<void> stopAlarm() async {
    ++_generation;
    _starting = false;
    _audioActive = false;
    _vibrationActive = false;
    _soundTimer?.cancel();
    _soundTimer = null;
    try {
      await Vibration.cancel();
    } catch (_) {}
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stopAlarm();
  }
}
