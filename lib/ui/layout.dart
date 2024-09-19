import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/mini_player/mini_player.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/now_playing/playing.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/search/search.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/home/home.dart';

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
  int _selectedIndex = 0;
  bool isMiniPlayerVisible = false;

  @override
  void initState() {
    super.initState();
    _tabs.addAll([
      HomeTab(onSongSelected: _updatePlayingSong), // Pass the callback
      const SearchTab(),
      const SettingsTab(),
    ]);
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
            duration: const Duration(milliseconds: 200), // Fade duration
            curve: Curves.easeInOut, // Smooth transition curve
            child: playingSong != null ? MiniPlayer(
              song: playingSong!,
              onPlayPause: () => {},
              onNext: () => {},
              onPrevious: () => {},
              onClose: () => setState(() {
                playingSong = null;
                isMiniPlayerVisible = false;
              }),
              isPlaying: true,  // Track your play state
            ) : const SizedBox.shrink(),
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
  }
}