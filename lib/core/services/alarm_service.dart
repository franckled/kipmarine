import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Continuous audible/haptic alert for anchor drift and man overboard.
///
/// The WAV is synthesized in memory so the alarm does not depend on a sound
/// asset being accidentally omitted from the iOS bundle.
class AlarmService {
  final AudioPlayer _player = AudioPlayer();
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

    try {
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      if (_disposed || generation != _generation) return;
      await _player.play(BytesSource(_createAlarmWave()));
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

  /// Creates a short, pulsing two-tone siren as mono 16-bit PCM WAV data.
  /// It is looped by audioplayers until stopAlarm() is called.
  static Uint8List _createAlarmWave() {
    const sampleRate = 22050;
    const durationSeconds = 2;
    const bytesPerSample = 2;
    const sampleCount = sampleRate * durationSeconds;
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
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // mono
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
      final envelope = pulse ? 0.72 : 0.0;
      final sample = (math.sin(2 * math.pi * frequency * seconds) *
              envelope *
              32767)
          .round()
          .clamp(-32768, 32767);
      header.setInt16(44 + i * bytesPerSample, sample, Endian.little);
    }
    return bytes;
  }

  Future<void> stopAlarm() async {
    ++_generation;
    _starting = false;
    _audioActive = false;
    _vibrationActive = false;
    _soundTimer?.cancel();
    _soundTimer = null;
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await Vibration.cancel();
    } catch (_) {}
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stopAlarm();
    await _player.dispose();
  }
}
