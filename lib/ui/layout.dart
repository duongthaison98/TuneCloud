import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/components/play_button.dart';
import 'package:music_app/components/song_navigator.dart';
import 'package:music_app/ui/mini_player/mini_player.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/search/search.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/home/home.dart';
import 'package:music_app/ui/now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,  // Set the default icon color to white
        ),
      ),
      home: const MusicLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicLayout extends StatefulWidget {
  const MusicLayout({super.key});

  @override
  State<MusicLayout> createState() => _MusicLayoutState();
}

class _MusicLayoutState extends State<MusicLayout> {
  final List<Widget> _tabs = [];

  List<Song> songs = [];
  Song? playingSong;
  int _selectedItemIndex = 0;
  bool isMiniPlayerVisible = false;
  bool _isShuffle = false;
  late LoopMode _loopMode = LoopMode.off;

  late AudioPlayerManager _audioPlayerManager;
  late SongNavigator songNavigator;

  @override
  void initState() {
    super.initState();
    _tabs.addAll([
      HomeTab(onSongSelected: _updatePlayingSong), // Pass the callback
      const SearchTab(),
      const SettingsTab(),
    ]);

    _audioPlayerManager = AudioPlayerManager();
    songNavigator = SongNavigator((newSong) {
      setState(() {
        playingSong = newSong;
        _selectedItemIndex++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: Colors.transparent,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home', activeIcon: Icon(Icons.home)),
              BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Search', activeIcon: Icon(Icons.saved_search)),
              BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings', activeIcon: Icon(Icons.settings))
            ],
            activeColor: Colors.white,
            inactiveColor: Colors.white70,
            iconSize: 25
          ),
          tabBuilder: (BuildContext context, int index) {
            return _getTabContent(index);
          }
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 50,
          child: AnimatedOpacity(
            opacity: isMiniPlayerVisible ? 1.0 : 0.0, // Animate opacity
            duration: const Duration(milliseconds: 300), // Fade duration
            curve: Curves.easeInOut, // Smooth transition curve
            child: playingSong != null
              ? GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(context,
                    CupertinoPageRoute(builder: (context) {
                      return NowPlaying(
                        songs: songs,
                        playingSong: playingSong!,
                        isShuffle: _isShuffle,
                        loopMode: _loopMode
                      );
                    })
                  );

                  print("---------result: $result");

                  if (result != null) {
                    setState(() {
                      _isShuffle = result['isShuffle'];
                      _loopMode = result['loopMode'];
                      playingSong = result['playingSong'];
                      songs = result['songs'];
                    });
                  }
                },
                child: MiniPlayer(
                  song: playingSong!,
                  isShuffle: _isShuffle,
                  loopMode: _loopMode,
                  onPlayPause: () => PlayButton(audioPlayerManager: _audioPlayerManager, buttonSize: 20),
                  onNext: () => songNavigator.navigateSong('next', _audioPlayerManager, songs, playingSong!, _selectedItemIndex, _isShuffle),
                  onPrevious: () => {},
                  onClose: () => setState(() {
                    playingSong = null;
                    isMiniPlayerVisible = false;
                  }),
                  isPlaying: true,  // Track your play state
                ),
              )
             : const SizedBox.shrink(),
          )
        )
      ]
    );
  }

  Widget _getTabContent(int index) {
    switch (index) {
      case 0:
        return HomeTab(onSongSelected: _updatePlayingSong);
      case 1:
        return const SearchTab();  // Pass appropriate callback if needed
      case 2:
        return const SettingsTab();
      default:
        return Container();
    }
  }

  void _updatePlayingSong(Song selectedSong, List<Song> songList) {
    // print("selectedSong: $selectedSong");
    // print("songList: $songList");
    setState(() {
      playingSong = selectedSong;
      songs = songList;
      isMiniPlayerVisible = true;
    });

    if (_audioPlayerManager.songUrl.compareTo(playingSong!.source) != 0) {
      _audioPlayerManager.updateSongUrl(playingSong!.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare(isNewSong: false);
    }

    _selectedItemIndex = songList.indexOf(selectedSong);

    _audioPlayerManager.player.setLoopMode(_loopMode);

    _audioPlayerManager.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        songNavigator.navigateSong('next', _audioPlayerManager, songs, playingSong!, _selectedItemIndex, _isShuffle);
      }
    });
  }
}