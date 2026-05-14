import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playCompletionSound() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/bell.mp3'));
    } catch (_) {
      // Missing or invalid asset shouldn't crash the timer.
    }
  }

  Future<void> dispose() => _player.dispose();
}
