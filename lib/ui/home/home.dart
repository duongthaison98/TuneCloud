import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/now_playing/playing.dart';
import 'package:music_app/data/model/song.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];

  late MusicAppViewModel _viewModel;

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

  @override
  Widget build(BuildContext context) {
    bool showLoading = songs.isEmpty;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black
      ),
      child: Scaffold(
        body: showLoading ? getProgressBar() : getListView()
      )
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    AudioPlayerManager().dispose();
    super.dispose();
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.only(
            left: 24,
            right: 9
          ),
          leading: ClipRRect(
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/itunes.png',
              image: songs[index].image,
              width: 48,
              height: 48,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/itunes.png', width: 48, height: 48);
              },
            ),
          ),
          title: Text(
            songs[index].title
          ),
          subtitle: Text(
            songs[index].artist,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              showBottomSheet();
            },
          ),
          onTap: () {
            Navigator.push(context,
              CupertinoPageRoute(builder: (context) {
                return NowPlaying(
                  songs: songs,
                  playingSong: songs[index]
                );
              })
            );
          },
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(context: context, builder: (context) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          height: 400,
          color: Colors.green,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Modal Bottom Sheet'),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Bottom Sheet')
                )
              ],
            ),
          )
        ),
      );
    });
  }
}