import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/home/home.dart';
import 'package:music_app/ui/search/search.dart';
import 'package:music_app/ui/settings/settings.dart';

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
  final List<Widget> _tabs = [
    const HomeTab(),
    const SearchTab(),
    const SettingsTab()
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  CupertinoTabScaffold(
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
        return _tabs[index];
      }
    );
  }
}