import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Continuous audible/haptic alert for anchor drift and man overboard.
/// The siren is generated in memory: it does not depend on a missing asset.
class AlarmService {
  final AudioPlayer _audioPlayer = AudioPlayer();
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

    try {
      await _audioPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      if (_disposed || generation != _generation) return;
      await _audioPlayer.play(BytesSource(_createAlarmWave()));
      if (!_disposed && generation == _generation) {
        _audioActive = true;
      }
    } catch (error) {
      _audioActive = false;
      debugPrint('KipMarine audible alarm failed: $error');
    }

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (generation != _generation || _disposed) return;
      if (hasVibrator == true) {
        await Vibration.vibrate(pattern: [500, 500, 500, 1000], repeat: 0);
        if (generation == _generation && !_disposed) {
          _vibrationActive = true;
        }
      }
    } catch (error) {
      _vibrationActive = false;
      debugPrint('KipMarine vibration alarm failed: $error');
    } finally {
      if (generation == _generation) _starting = false;
    }
  }

  static Uint8List _createAlarmWave() {
    const sampleRate = 22050;
    const sampleCount = sampleRate * 2;
    const bytesPerSample = 2;
    const dataLength = sampleCount * bytesPerSample;
    final bytes = Uint8List(44 + dataLength);
    final header = ByteData.sublistView(bytes);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes[offset + i] = value.codeUnitAt(i);
      }
    }

    writeAscii(0, 'RIFF');
    header.setUint32(4, 36 + dataLength, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * bytesPerSample, Endian.little);
    header.setUint16(32, bytesPerSample, Endian.little);
    header.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    header.setUint32(40, dataLength, Endian.little);

    for (var i = 0; i < sampleCount; i++) {
      final seconds = i / sampleRate;
      final pulse = (seconds % 0.5) < 0.34;
      final frequency = (seconds % 1.0) < 0.5 ? 880.0 : 660.0;
      final sample = (math.sin(2 * math.pi * frequency * seconds) *
              (pulse ? 0.72 : 0.0) *
              32767)
          .round()
          .clamp(-32768, 32767)
          .toInt();
      header.setInt16(44 + i * bytesPerSample, sample, Endian.little);
    }
    return bytes;
  }

  Future<void> stopAlarm() async {
    ++_generation;
    _starting = false;
    _audioActive = false;
    _vibrationActive = false;
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    try {
      await Vibration.cancel();
    } catch (_) {}
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stopAlarm();
    try {
      await _audioPlayer.dispose();
    } catch (_) {}
  }
}
