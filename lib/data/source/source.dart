import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/song.dart';

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    final String res = await rootBundle.loadString('assets/songs.json');
    final jsonBody = jsonDecode(res) as Map;
    final songList = jsonBody['songs'] as List;
    List<Song> songs = songList.map((song) => Song.formJson(song)).toList();
    return songs;
  }
}
