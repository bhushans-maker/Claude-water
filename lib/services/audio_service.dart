import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../models/user_profile.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  /// Start alarm audio + vibration loop
  static Future<void> startAlarm(AlarmTune tune) async {
    if (_isPlaying) return;
    _isPlaying = true;

    // Start vibration pattern loop
    _startVibration();

    // Play audio on loop
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      // Use a bundled asset tone (fallback to system beep if asset missing)
      await _player.play(AssetSource('audio/${tune.fileName}'));
    } catch (e) {
      // If custom tune not found, try generic fallback
      try {
        await _player.play(AssetSource('audio/water_droplets.mp3'));
      } catch (_) {}
    }
  }

  static Future<void> _startVibration() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    // Vibrate in pattern: wait 0ms, vibrate 800ms, pause 500ms, vibrate 800ms...
    while (_isPlaying) {
      await Vibration.vibrate(
        pattern: [0, 800, 500, 800, 500, 800],
        intensities: [0, 200, 0, 200, 0, 200],
      );
      await Future.delayed(const Duration(milliseconds: 3000));
    }
  }

  /// Stop alarm audio + vibration
  static Future<void> stopAlarm() async {
    _isPlaying = false;
    await _player.stop();
    await Vibration.cancel();
  }

  /// Preview a tune (plays once)
  static Future<void> previewTune(AlarmTune tune) async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.play(AssetSource('audio/${tune.fileName}'));
    } catch (_) {}
  }

  static bool get isPlaying => _isPlaying;
}
