import 'package:audioplayers/audioplayers.dart';

class AudioPlayWithURL {
  final AudioPlayer audioPlayer = AudioPlayer();
  void playSound(path) {
    audioPlayer.play(AssetSource(path));
  }
}
