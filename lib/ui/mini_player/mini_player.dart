import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/model/song.dart';
import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  final Song song;
  final Function onPlayPause;
  final Function onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;
  final bool isPlaying;
  final bool isShuffle;
  final LoopMode loopMode;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
    required this.isPlaying,
    required this.isShuffle,
    required this.loopMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF411919),
        borderRadius: BorderRadius.circular(5)
      ),
      padding: const EdgeInsets.only(top: 5, right: 0, bottom: 5, left: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              song.image, // Replace with actual song image
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/itunes.png', width: 48, height: 48);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.none),
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 5),
                Text(
                  song.artist,
                  style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.none),
                  overflow: TextOverflow.ellipsis
                )
              ]
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              onPlayPause(),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {
                  onNext();
                }
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  onClose();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}