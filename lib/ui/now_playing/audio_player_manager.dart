
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  AudioPlayerManager._internal();
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl = "";

  void prepare({bool isNewSong = false}) {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(progress: position, buffered: playbackEvent.bufferedPosition, total: playbackEvent.duration)
    );

    if (isNewSong) {
      player.setUrl(songUrl);
      player.play();
    }
  }

  void updateSongUrl(String url) {
    songUrl = url;
    prepare(isNewSong: true);
  }

  void dispose() {
    player.dispose();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    required this.total
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}