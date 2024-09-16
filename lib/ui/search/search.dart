import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/now_playing/playing.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchPage();
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;
  String searchQuery  = '';
  List<Song> filteredSongs  = [];

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();

    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList as Iterable<Song>);
      });
    });
    super.initState();
  }

  void _filterSongs(String query) {
    setState(() {
      searchQuery = query;
      filteredSongs = songs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.artist.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showLoading = filteredSongs.isEmpty;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Search', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoTextField(
              placeholder: 'What do you want to hear',
              onChanged: _filterSongs,
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Icon(CupertinoIcons.search),
              ),
              autofocus: false,
              style: const TextStyle(color: CupertinoColors.white),
              placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey2),
              decoration: BoxDecoration(
                boxShadow: const [],
                color: CupertinoColors.systemGrey5, // Grey background
                borderRadius: BorderRadius.zero,    // No border radius
                border: Border.all(color: CupertinoColors.systemGrey5, width: 0), // No border
              ),
              padding: const EdgeInsets.symmetric(vertical: 15)
            ),
            Expanded(
              child: showLoading ? emptySearch() : getListView(),
            )
          ],
        )
      )
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    filteredSongs = [];
    super.dispose();
  }

  Widget emptySearch() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Play content you like', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.none)),
            SizedBox(height: 10),
            Text('Search for songs, artist, anything you want.', style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.none)),
          ],
        )
      )
    );
  }

  ListView getListView() {
    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        return Material(
          color: Colors.black,
          child: ListTile(
            contentPadding: const EdgeInsets.only(
              left: 24,
              right: 9
            ),
            leading: ClipRRect(
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/itunes.png',
                image: filteredSongs[index].image,
                width: 48,
                height: 48,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/itunes.png', width: 48, height: 48);
                },
              ),
            ),
            title: Text(filteredSongs[index].title),
            subtitle: Text(
              filteredSongs[index].artist,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12
              ),
            ),
            onTap: () {
              Navigator.push(context,
                CupertinoPageRoute(builder: (context) {
                  return NowPlaying(
                    songs: filteredSongs,
                    playingSong: filteredSongs[index]
                  );
                })
              );
            },
          )
        );
      },
    );
  }
}
