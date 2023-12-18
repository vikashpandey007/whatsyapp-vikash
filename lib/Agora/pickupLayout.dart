// import 'package:WhatsYapp/Agora/incomingCall.dart';
// import 'package:flutter/material.dart';

// class PickUpLayout extends StatefulWidget {
//   const PickUpLayout({super.key});

//   @override
//   State<PickUpLayout> createState() => _PickUpLayoutState();
// }

// class _PickUpLayoutState extends State<PickUpLayout> {
//   AgoraRTMManager _agoraRTMManager = AgoraRTMManager();
//   Widget _buildRemoteInvitation() {
//     if (!_isLogin || _remoteInvitation == null) {
//       return Container();
//     }
//     return Row(children: <Widget>[
//       OutlinedButton(
//         onPressed: _agoraRTMManager.acceptCallInvitation(invitation),
//         child: Text('accept remote invitation', style: textStyle),
//       ),
//       OutlinedButton(
//         onPressed: _refuseRemoteInvitation,
//         child: Text('refuse remote invitation', style: textStyle),
//       )
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _buildRemoteInvitation(),
//     );
//   }
// }
