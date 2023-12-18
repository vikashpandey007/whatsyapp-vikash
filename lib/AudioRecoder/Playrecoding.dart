import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:WhatsYapp/dependencies/Auth/firebase_storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ap;

class AudioPlayerClass extends StatefulWidget {
  /// Path from where to play recorded audio
  final ap.AudioSource source;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  final VoidCallback onDelete;

  final void Function(String? path) send;

  AudioPlayerClass(
      {required this.source,
      required this.onDelete,
      required this.send,
      this.url});
  String? url;

  @override
  AudioPlayerClassState createState() => AudioPlayerClassState();
}

class AudioPlayerClassState extends State<AudioPlayerClass> {
  static const double _controlSize = 56;
  static const double _deleteBtnSize = 20;

  final _audioPlayer = ap.AudioPlayer();
  late StreamSubscription<ap.PlayerState> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;

  @override
  void initState() {
    _playerStateChangedSubscription =
        _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ap.ProcessingState.completed) {
        await stop();
      }
      setState(() {});
    });
    _positionChangedSubscription =
        _audioPlayer.positionStream.listen((position) => setState(() {}));
    _durationChangedSubscription =
        _audioPlayer.durationStream.listen((duration) => setState(() {}));
    _init();

    super.initState();
  }

  Future<void> _init() async {
    await _audioPlayer.setAudioSource(widget.source);
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  bool sendFile = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildControl(),
        _buildSlider(),
        IconButton(
          icon: Icon(Icons.delete,
              color: const Color(0xFF73748D), size: _deleteBtnSize),
          onPressed: () {
            _audioPlayer.stop().then((value) => widget.onDelete());
          },
        ),
        sendFile == false
            ? IconButton(
                icon: Icon(
                  Icons.send,
                  color: Color(0xFF73748D),
                  size: 25,
                ),
                onPressed: () async {
                  setState(() {
                    sendFile = !sendFile;
                  });
                  File? file = File(widget.url as String);
                  String? url =
                      await firebaseStorage().storeFileToStorage(file);

                  _audioPlayer.stop().then((value) async {
                    print(url);

                    widget.send(url);
                  });
                },
              )
            : CircularProgressIndicator(
                color: Color(0xff139ea1),
              ),
      ],
    );
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_audioPlayer.playerState.playing) {
      icon = Icon(Icons.pause, color: Color(0xff139ea1), size: 20);
      color = Color(0xff139ea1).withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.play_arrow, color: theme.primaryColor, size: 20);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child:
              SizedBox(width: _controlSize, height: _controlSize, child: icon),
          onTap: () {
            if (_audioPlayer.playerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider() {
    final position = _audioPlayer.position;
    final duration = _audioPlayer.duration;
    bool canSetValue = false;
    if (duration != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    return SizedBox(
      width: 160,
      child: Slider(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).canvasColor,
        onChanged: (v) {
          if (duration != null) {
            final position = v * duration.inMilliseconds;
            _audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value: canSetValue && duration != null
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0,
      ),
    );
  }

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    return _audioPlayer.seek(const Duration(milliseconds: 0));
  }
}
