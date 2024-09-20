import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/now_playing/playing.dart';

class PlayButton extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final double buttonSize;

  const PlayButton({super.key, required this.audioPlayerManager, required this.buttonSize});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState> (
      stream: audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;
        if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: buttonSize,
            height: buttonSize,
            child: const CircularProgressIndicator(color: Colors.white),
          );
        } else if (playing != true) {
          return MediaButtonControl(
            function: () {
              audioPlayerManager.player.play();
            },
            icon: Icons.play_arrow,
            color: Colors.white,
            size: buttonSize
          );
        } else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              audioPlayerManager.player.pause();
            },
            icon: Icons.pause,
            color: Colors.white,
            size: buttonSize
          );
        } else {
          return MediaButtonControl(
            function: () {
              audioPlayerManager.player.seek(Duration.zero);
            },
            icon: Icons.replay,
            color: Colors.white,
            size: buttonSize
          );
        }
      }
    );
  }
}
