import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';
import 'package:flutter/material.dart';

class AudioRecorderSoundClass extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorderSoundClass({required this.onStop});

  @override
  _AudioRecorderSoundClassState createState() =>
      _AudioRecorderSoundClassState();
}

class _AudioRecorderSoundClassState extends State<AudioRecorderSoundClass> {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  //final _audioRecorder = AudioRecorder();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  RecorderController recorderController = RecorderController();
  // final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _isPlaying = false;
  String? _path;

  @override
  void initState() {
    _isRecording = false;
    super.initState();
    _init();
    _start();
  }

  Future<void> _init() async {
    await _recorder.openRecorder();
    // await _player.openPlayer();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _recorder.startRecorder();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText(),
              const SizedBox(width: 20),
              waveControl(),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRecordStopControl(),
            const SizedBox(width: 20),
            _buildPauseResumeControl(),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }

  Widget waveControl() {
    return AudioWaveforms(
        enableGesture: true,
        size: Size(MediaQuery.of(context).size.width / 2, 50),
        recorderController: recorderController,
        waveStyle: const WaveStyle(
          waveColor: Colors.grey,
          extendWaveform: true,
          showMiddleLine: false,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          //color: const Color(0xFF1E1B26),
        ),
        padding: const EdgeInsets.only(left: 18),
        margin: const EdgeInsets.symmetric());
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_isRecording) {
      icon = Icon(Icons.stop, color: Color(0xff139ea1), size: 30);
      color = Color(0xff139ea1).withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: Colors.green, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            _stop();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (!_isRecording && !_isPaused) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (_isRecording || _isPaused) {
      icon = Icon(Icons.pause, color: Color(0xff139ea1), size: 20);
      color = Color(0xff139ea1).withOpacity(0.1);
    } else {
      icon = Icon(Icons.play_arrow, color: Color(0xff139ea1), size: 30);
      color = Color(0xff139ea1).withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            _isRecording ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_isRecording || _isPaused) {
      return _buildTimer();
    }

    return Text("");
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: TextStyle(color: Color(0xff139ea1)),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/myRecording.aac';
  }

  Future<void> _start() async {
    try {
      print("recording started");
      String? path = await getFilePath();
      print(path);

      await recorderController.record();
      bool isRecording = await recorderController.isRecording;
      print(isRecording);
      setState(() {
        _isRecording = isRecording;
        print("_isRecording == ${_isRecording}");
        _recordDuration = 0;
      });

      _startTimer();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    print("stop");
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await recorderController.stop();
    print("path === $path");
    widget.onStop(path!);

    setState(() => _isRecording = false);
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await recorderController.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _recorder.resumeRecorder();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      setState(() {});
    });
  }
}
