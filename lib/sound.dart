import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class DmcAudio {
  static final AudioPlayer _player = AudioPlayer();
  static bool soundEnabled = true;

  static void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  static Future<void> playSlash() async {
    HapticFeedback.lightImpact();
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/slash.wav'), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  static Future<void> playCorrect() async {
    HapticFeedback.mediumImpact();
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/correct.wav'), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  static Future<void> playWrong() async {
    HapticFeedback.heavyImpact();
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/wrong.wav'), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  static Future<void> playRankUp() async {
    HapticFeedback.mediumImpact();
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/rankup.wav'), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  static Future<void> playStageClear() async {
    HapticFeedback.heavyImpact();
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/stageclear.wav'));
    } catch (_) {}
  }
}
