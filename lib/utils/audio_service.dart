import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true;
  
  // Sound types
  static const String inhale = 'inhale.wav';
  static const String exhale = 'exhale.wav';
  static const String hold = 'hold.wav';
  static const String complete = 'complete.wav';
  
  AudioService();
  
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  Future<void> playSound(String soundFile) async {
    if (!_isEnabled) return;
    
    try {
      await _player.setAsset('assets/sounds/$soundFile');
      await _player.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
  
  Future<void> dispose() async {
    await _player.dispose();
  }
}