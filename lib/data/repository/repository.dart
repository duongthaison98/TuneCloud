import 'package:music_app/data/source/source.dart';

import '../model/song.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];

    await _localDataSource.loadData().then((localSongs) {
      if (localSongs != null) {
        songs.addAll(localSongs as Iterable<Song>);
      }
    });

    return songs;
  }
}