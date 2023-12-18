import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
// import 'package:audioplayers/notifications.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
  final String? url;

  const PlayerWidget({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  AudioPlayer audioPlayer = new AudioPlayer();
  Duration duration = new Duration();
  Duration position = new Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BubbleNormalAudio(
          color: Color(0xFFE8E8EE),
          duration: duration.inSeconds.toDouble(),
          position: position.inSeconds.toDouble(),
          isPlaying: isPlaying,
          isLoading: isLoading,
          isPause: isPause,
          onSeekChanged: _changeSeek,
          onPlayPauseButtonClick: _playAudio,
          sent: true,
          
        ),
      ],
    );
  }

  void _changeSeek(double value) {
    setState(() {
      audioPlayer.seek(new Duration(seconds: value.toInt()));
    });
  }

  void _playAudio() async {
    if (isPause) {
      await audioPlayer.resume();
      setState(() {
        isPlaying = true;
        isPause = false;
      });
    } else if (isPlaying) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
        isPause = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
      await audioPlayer.play(UrlSource(widget.url.toString()));
      setState(() {
        isPlaying = true;
      });
    }

    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        duration = d;
        isLoading = false;
      });
    });
    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        position = p;
      });
    });
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        duration = new Duration();
        position = new Duration();
      });
    });
  }
}
