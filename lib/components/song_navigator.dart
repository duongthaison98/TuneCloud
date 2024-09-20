import 'dart:math';

import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';

class SongNavigator {
  final void Function(Song) onSongChanged;

  SongNavigator(this.onSongChanged);

  void navigateSong(String type, AudioPlayerManager audioPlayerManager, List<Song> songs, Song playingSong, int selectedItemIndex, bool isShuffle) {
    print("-------isShuffle: $isShuffle");
    if (isShuffle) {
      selectedItemIndex = Random().nextInt(songs.length);
    } else {
      if (type == 'prev' && selectedItemIndex > 0) {
        selectedItemIndex--;
      } else if (type == 'next' && selectedItemIndex < songs.length - 1) {
        selectedItemIndex++;
      } else {
        return; // If out of bounds, do nothing
      }
    }

    print("------------selectedItemIndex: $selectedItemIndex");

    final newSong = songs[selectedItemIndex];
    audioPlayerManager.updateSongUrl(newSong.source);

    onSongChanged(newSong);
  }
}