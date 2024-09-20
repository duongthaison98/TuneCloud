import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/components/play_button.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.songs, required this.playingSong, required this.isShuffle, required this.loopMode});

  final Song playingSong;
  final List<Song> songs;
  final bool isShuffle;
  final LoopMode loopMode;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
      isShuffle: isShuffle,
      loopMode: loopMode
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key, required this.songs, required this.playingSong, required this.isShuffle, required this.loopMode});

  final List<Song> songs;
  final Song playingSong;
  final bool isShuffle;
  final LoopMode loopMode;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with SingleTickerProviderStateMixin {
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  late bool _isShuffle;
  late LoopMode _loopMode;

  bool _isFavorite = false;

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1000)
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _audioPlayerManager = AudioPlayerManager();
    if (_audioPlayerManager.songUrl.compareTo(_song.source) != 0) {
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare(isNewSong: false);
    }

    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);

    _isShuffle = widget.isShuffle;
    _loopMode = widget.loopMode;

    _audioPlayerManager.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _navigateSong('next');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 45;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: (
          IconButton(
            icon: const Icon(CupertinoIcons.chevron_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context, {
                'isShuffle': _isShuffle,
                'loopMode': _loopMode,
                'playingSong': _song,
                'songs': widget.songs
              });
            }
          )
        ),
        middle: const Text('Now playing', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent
      ),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text('Album', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(_song.album, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 48),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/itunes.png',
                    image: _song.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/itunes.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 16),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_song.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                            const SizedBox(height: 5),
                            Text(_song.artist, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.left)
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                            _showSnackBar(_isFavorite ? 'Added to favorites' : 'Removed from favorites');
                          },
                          icon: !_isFavorite ? const Icon(Icons.favorite_outline) : const Icon(Icons.favorite)
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 26, right: 24, bottom: 16),
                  child: _progressBar()
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 16),
                  child: _mediaButtons()
                )
              ],
            )
          )
        ),
      )
    );
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MediaButtonControl(function: _setShuffle, icon: Icons.shuffle, color: _getShuffleColor(), size: 24),
          MediaButtonControl(function: () => _navigateSong('prev'), icon: Icons.skip_previous, color: Colors.white, size: 36),
          PlayButton(audioPlayerManager: _audioPlayerManager, buttonSize: 48),
          MediaButtonControl(function: () => _navigateSong('next'), icon: Icons.skip_next, color: Colors.white, size: 36),
          MediaButtonControl(function: _setRepeat, icon: _getRepeatIcon(), color: _getRepeatColor(), size: 24)
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;

        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
          onSeek: _audioPlayerManager.player.seek,
          barHeight: 3,
          barCapShape: BarCapShape.round,
          baseBarColor: Colors.grey.withOpacity(0.3),
          progressBarColor: Colors.white,
          bufferedBarColor: Colors.transparent,
          thumbColor: Colors.white,
          thumbGlowColor: Colors.transparent,
          thumbRadius: 5.0,
          timeLabelTextStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          timeLabelPadding: 4
        );
      }
    );
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Colors.green : Colors.white;
  }

  void _navigateSong(String type) {
    if (_isShuffle) {
      _selectedItemIndex = Random().nextInt(widget.songs.length);
    } else {
      if (type == 'prev' && _selectedItemIndex > 0) {
        _selectedItemIndex--;
      } else if (type == 'next' && _selectedItemIndex < widget.songs.length - 1) {
        _selectedItemIndex++;
      } else {
        return;  // If the index is out of bounds, return early
      }
    }

    final newSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(newSong.source);

    setState(() {
      _song = newSong;
    });
  }

  void _setRepeat() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }

    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  Color? _getRepeatColor() {
    return _loopMode == LoopMode.one ? Colors.green : Colors.white;
  }

  IconData _getRepeatIcon() {
    return _loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat;
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary
    );
  }
}