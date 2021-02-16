import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class MediaPlayer{
  static AudioPlayer _audioPlayer = AudioPlayer();
  static final _audioCache = AudioCache(fixedPlayer: _audioPlayer);

  static Future playAudio(String path) async{
    await stopAudio();
    await _audioCache.play(path);
  }

  static stopAudio()  {
    _audioPlayer?.stop();
  }
}