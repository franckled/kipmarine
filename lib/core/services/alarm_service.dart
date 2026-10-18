import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlarmService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Déclenche la sirène d'alarme et les vibrations
  Future<void> triggerAlarm() async {
    if (_isPlaying) return;
    _isPlaying = true;

    // Vibration en boucle
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
    }

    // Lecture du son en boucle
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // Utilise un son d'alerte système ou un asset local
    await _audioPlayer.play(AssetSource('sounds/anchor_alarm.wav'));
  }

  /// Arrête l'alarme et les vibrations
  Future<void> stopAlarm() async {
    _isPlaying = false;
    await Vibration.cancel();
    await _audioPlayer.stop();
  }
}
