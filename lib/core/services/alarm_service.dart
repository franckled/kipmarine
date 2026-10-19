import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

/// Sound and vibration output for the anchor-drift alarm.
///
/// Platform failures are handled independently: a vibration failure must not
/// prevent the sound from starting, and vice versa.
class AlarmService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioActive = false;
  bool _vibrationActive = false;
  bool _disposed = false;

  bool get isPlaying => _audioActive || _vibrationActive;

  /// Starts the looping alarm. The caller may retry on a later GPS update if
  /// neither audio nor vibration can be started.
  Future<void> triggerAlarm() async {
    if (_disposed || isPlaying) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(
          pattern: [500, 1000, 500, 1000],
          repeat: 0,
        );
        _vibrationActive = true;
      }
    } catch (_) {
      _vibrationActive = false;
    }

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/anchor_alarm.wav'));
      _audioActive = true;
    } catch (_) {
      _audioActive = false;
    }
  }

  /// Stops all alarm outputs, even if one platform channel fails.
  Future<void> stopAlarm() async {
    _audioActive = false;
    _vibrationActive = false;

    try {
      await Vibration.cancel();
    } catch (_) {
      // Audio must still be stopped if vibration is unavailable.
    }

    try {
      await _audioPlayer.stop();
    } catch (_) {
      // The player may not be initialized on this platform.
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stopAlarm();
    try {
      await _audioPlayer.dispose();
    } catch (_) {
      // No further action is possible during teardown.
    }
  }
}
