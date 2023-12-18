import 'dart:async';
import 'package:WhatsYapp/Agora/incomingCall.dart';
import 'package:WhatsYapp/Util/AgoraId.dart';
import 'package:WhatsYapp/agoraTokenCreation/agoraTokenCreation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraVideoCall extends StatefulWidget {
  final user, client, client_profile, token, channnelId, user_profile;

  AgoraVideoCall(
      {super.key,
      required this.user,
      required this.client,
      this.client_profile,
      this.token,
      this.channnelId,
      this.user_profile});

  @override
  _AgoraVideoCallState createState() => _AgoraVideoCallState();
}

class _AgoraVideoCallState extends State<AgoraVideoCall> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool isSpeakerOn = false;
  bool _isCameraOn = true;
  late Timer callTimer;
  Duration callDuration = Duration();
  late DatabaseReference voiceCall_ref, conversations_ref, messages_ref;
  late final FirebaseAuth auth;

  @override
  void dispose() {
    _dispose();
    stopCallTimer();

    super.dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
    messages_ref.onDisconnect();
    voiceCall_ref.onDisconnect();
    conversations_ref.onDisconnect();
  }

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    messages_ref = FirebaseDatabase.instance
        .ref()
        .child('Messages/${widget.user}_${widget.client}');
    conversations_ref = FirebaseDatabase.instance
        .ref()
        .child('Conversations/${widget.user}_${widget.client}');

    voiceCall_ref = FirebaseDatabase.instance
        .ref()
        .child('Video Calls/${widget.user}_${widget.client}');
    initAgora();
  }

  updateFirebaseCallDetails() async {
    DatabaseReference push_key = messages_ref.push();
    try {
      await push_key.set({
        'file_name': '',
        'media_url': "",
        //  'read_status': 'false',
        'receiver_id': widget.client,
        'sender_id': auth.currentUser!.phoneNumber,
        'text': formatDuration(callDuration),
        'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
        'type': "video_call",
      });
      await voiceCall_ref.push().set({
        'file_name': '',
        'media_url': "",
        //  'read_status': 'false',
        'receiver_id': widget.client,
        'sender_id': auth.currentUser!.phoneNumber,
        'text': formatDuration(callDuration),
        'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
        'type': "video_call",
      });

      await conversations_ref.update({
        'client': widget.client,
        'created_at': (Moment.now().millisecondsSinceEpoch).toString(),
        'last_message': push_key.key,
        'last_message_sender_id': widget.client,
        'last_message_text': formatDuration(callDuration),
        'last_message_timestamp':
            (Moment.now().millisecondsSinceEpoch).toString(),
        'user_pp': widget.user_profile,
        'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
        'unread_count_client': ServerValue.increment(1),
        'user': widget.user,
      });

      return 'Success';
    } catch (error) {
      print('Error storing user data: $error');
      return 'Failure';
    }
  }

  void startCallTimer() {
    callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        callDuration = Duration(seconds: callDuration.inSeconds + 1);
      });
    });
  }

  void stopCallTimer() {
    callTimer.cancel();
  }

  /// Add agora event handlers
  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appIDTesting,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
            startCallTimer();
            AgoraRTMManager().initializeRTM(appIDTesting, "123");
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channnelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Center(
              child: _remoteVideo(),
            ),

            //

            _remoteUid == null
                ? SizedBox(
                    child: Center(
                      child: _localUserJoined
                          ? AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: _engine,
                                canvas: const VideoCanvas(),
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: Center(
                          child: _localUserJoined
                              ? AgoraVideoView(
                                  controller: VideoViewController(
                                    rtcEngine: _engine,
                                    canvas: const VideoCanvas(uid: 0),
                                  ),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),

            // Controls overlay
            Column(
              children: [
                SizedBox(height: 50),
                Text(
                  'End-to_end encrypted',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                SizedBox(height: 50),
                _remoteUid == null
                    ? Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.client,
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )
                    : Container(),
                _remoteUid == null
                    ? Center(
                        child: Text(
                          'Ringing',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      )
                    : Text(
                        'Joined',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                color: Colors.grey[600],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft:
                        Radius.circular(20.0), // Adjust the radius as needed
                    topRight: Radius.circular(20.0),
                  ),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.cameraswitch,
                        ),
                        iconSize: 32,
                        onPressed: _onSwitchCamera,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(
                            _isCameraOn ? Icons.videocam : Icons.videocam_off),
                        iconSize: 32,
                        onPressed: toggleCamera,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(
                          muted ? Icons.mic_off : Icons.mic,
                        ),
                        iconSize: 32,
                        onPressed: _onToggleMute,
                        color: Colors.white,
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.call_end),
                          iconSize: 30,
                          onPressed: () => _onCallEnd(context),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Agora Video Call'),
    //   ),
    //   body: Stack(
    //     children: [
    //       Center(
    //         child: _remoteVideo(),
    //       ),
    //       Align(
    //         alignment: Alignment.bottomRight,
    //         child: SizedBox(
    //           width: 100,
    //           height: 150,
    //           child: Center(
    //             child: _localUserJoined
    //                 ? AgoraVideoView(
    //                     controller: VideoViewController(
    //                       rtcEngine: _engine,
    //                       canvas: const VideoCanvas(uid: 0),
    //                     ),
    //                   )
    //                 : const CircularProgressIndicator(),
    //           ),
    //         ),
    //       ),
    //       _toolbar()
    //     ],
    //   ),
    // );
  }

  void toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
      _engine.enableLocalVideo(_isCameraOn);
    });
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channnelId),
        ),
      );
    } else {
      return const Text(
        '',
        textAlign: TextAlign.center,
      );
    }
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
    updateFirebaseCallDetails();
    stopCallTimer();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}
