// import 'dart:async';
// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
// import 'package:flutter/material.dart';

// class AudioRecorderClass extends StatefulWidget {
//   final void Function(String path) onStop;

//   const AudioRecorderClass({required this.onStop});

//   @override
//   _AudioRecorderClassState createState() => _AudioRecorderClassState();
// }

// class _AudioRecorderClassState extends State<AudioRecorderClass> {
//   bool _isRecording = false;
//   bool _isPaused = false;
//   int _recordDuration = 0;
//   Timer? _timer;
//   Timer? _ampTimer;
//   final _audioRecorder = AudioRecorder();

//   @override
//   void initState() {
//     _isRecording = false;
//     super.initState();
//     _start();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _ampTimer?.cancel();
//     _audioRecorder.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _buildRecordStopControl(),
//             const SizedBox(width: 20),
//             _buildPauseResumeControl(),
//             const SizedBox(width: 20),
//             _buildText(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildRecordStopControl() {
//     late Icon icon;
//     late Color color;

//     if (_isRecording || _isPaused) {
//       icon = Icon(Icons.stop, color: Color(0xff139ea1), size: 30);
//       color = Color(0xff139ea1).withOpacity(0.1);
//     } else {
//       final theme = Theme.of(context);
//       icon = Icon(Icons.mic, color: Colors.green, size: 30);
//       color = theme.primaryColor.withOpacity(0.1);
//     }

//     return ClipOval(
//       child: Material(
//         color: color,
//         child: InkWell(
//           child: SizedBox(width: 56, height: 56, child: icon),
//           onTap: () {
//             _isRecording ? _stop() : _start();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildPauseResumeControl() {
//     if (!_isRecording && !_isPaused) {
//       return const SizedBox.shrink();
//     }

//     late Icon icon;
//     late Color color;

//     if (!_isPaused) {
//       icon = Icon(Icons.pause, color: Color(0xff139ea1), size: 20);
//       color = Color(0xff139ea1).withOpacity(0.1);
//     } else {
//       icon = Icon(Icons.play_arrow, color: Color(0xff139ea1), size: 30);
//       color = Color(0xff139ea1).withOpacity(0.1);
//     }

//     return ClipOval(
//       child: Material(
//         color: color,
//         child: InkWell(
//           child: SizedBox(width: 56, height: 56, child: icon),
//           onTap: () {
//             _isPaused ? _resume() : _pause();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildText() {
//     if (_isRecording || _isPaused) {
//       return _buildTimer();
//     }

//     return Text("");
//   }

//   Widget _buildTimer() {
//     final String minutes = _formatNumber(_recordDuration ~/ 60);
//     final String seconds = _formatNumber(_recordDuration % 60);

//     return Text(
//       '$minutes : $seconds',
//       style: TextStyle(color: Color(0xff139ea1)),
//     );
//   }

//   String _formatNumber(int number) {
//     String numberStr = number.toString();
//     if (number < 10) {
//       numberStr = '0' + numberStr;
//     }

//     return numberStr;
//   }

//   Future<String> getFilePath() async {
//     final directory = await getApplicationDocumentsDirectory();
//     return '${directory.path}/myFile.m4a';
//   }

//   Future<void> _start() async {

//     try {
//       if (await _audioRecorder.hasPermission()) {
//         print("recording started");
//         String? path = await getFilePath();
//         print(path);
//         await _audioRecorder.start(path: path, const RecordConfig());
//          final stream = await _audioRecorder.startStream(const RecordConfig());

//         bool isRecording = await _audioRecorder.isRecording();
//         print(isRecording);
//         setState(() {
//           _isRecording = isRecording;
//           print("_isRecording == ${_isRecording}");
//           _recordDuration = 0;
//         });

//         _startTimer();
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _stop() async {
//     print("stop");
//     _timer?.cancel();
//     _ampTimer?.cancel();
//     final path = await _audioRecorder.stop();
//     print("path === $path");
//     widget.onStop(path!);

//     setState(() => _isRecording = false);
//   }

//   Future<void> _pause() async {
//     _timer?.cancel();
//     _ampTimer?.cancel();
//     await _audioRecorder.pause();

//     setState(() => _isPaused = true);
//   }

//   Future<void> _resume() async {
//     _startTimer();
//     await _audioRecorder.resume();

//     setState(() => _isPaused = false);
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _ampTimer?.cancel();

//     _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
//       setState(() => _recordDuration++);
//     });

//     _ampTimer =
//         Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
//       setState(() {});
//     });
//   }
// }
