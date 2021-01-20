// 音声再生
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

class SoundUtil {
  static AudioCache player = AudioCache(fixedPlayer: audioPlayer);

  SoundUtil() {
    player.disableLog();
    player.load("sounds/alarm.mp3");
  }

  static void playAssetSound(String assetPath) {
    if (assetPath == null) {
      assetPath = "sounds/alarm.mp3";
    }
    player.play(assetPath);
  }
}
