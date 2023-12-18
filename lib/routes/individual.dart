// // import 'package:camera/camera.dart';
// // import 'package:chatapp/CustomUI/CameraUI.dart';

// // import 'package:Chat/models/chat_model.dart';
// import 'package:WhatsYapp/Chat/models/chat_model.dart';
// import 'package:WhatsYapp/Chat/models/message_model.dart';
// // import 'package:chatapp/Model/MessageModel.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// class IndividualPage extends StatefulWidget {
//   const IndividualPage({
//    // required this.chatModel,
//   });
//  // final ChatModel chatModel;
//   // final ChatModel sourchat;

//   @override
//   _IndividualPageState createState() => _IndividualPageState();
// }

// class _IndividualPageState extends State<IndividualPage> {
//   bool show = false;
//   FocusNode focusNode = FocusNode();
//   bool sendButton = false;
//  // List<MessageModel> messages = [];
//   TextEditingController _controller = TextEditingController();
//   ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     // connect();
//   }

//   // void setMessage(String type, String message) {
//   //   MessageModel messageModel = MessageModel(
//   //       type: type,
//   //       message: message,
//   //       time: DateTime.now().toString().substring(10, 16));
//   //   print(messages);

//   //   setState(() {
//   //     messages.add(messageModel);
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Image.asset(
//           "assets/whatsapp_Back.png",
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           fit: BoxFit.cover,
//         ),
//         Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(60),
//             child: AppBar(
//               leadingWidth: 70,
//               titleSpacing: 0,
//               leading: InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.arrow_back,
//                       size: 24,
//                     ),
//                     CircleAvatar(
//                       child: SvgPicture.asset(
//                         widget.chatModel.isGroup
//                             ? "assets/groups.svg"
//                             : "assets/person.svg",
//                         color: Colors.white,
//                         height: 36,
//                         width: 36,
//                       ),
//                       radius: 20,
//                       backgroundColor: Colors.blueGrey,
//                     ),
//                   ],
//                 ),
//               ),
//               title: InkWell(
//                 onTap: () {},
//                 child: Container(
//                   margin: const EdgeInsets.all(6),
//                   child: const Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Text(
//                       //   widget.chatModel.name,
//                       //   style: TextStyle(
//                       //     fontSize: 18.5,
//                       //     fontWeight: FontWeight.bold,
//                       //   ),
//                       // ),
//                       // Text(
//                       //   "last seen today at 12:05",
//                       //   style: TextStyle(
//                       //     fontSize: 13,
//                       //   ),
//                       // )
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
//                 IconButton(icon: const Icon(Icons.call), onPressed: () {}),
//                 PopupMenuButton<String>(
//                   padding: const EdgeInsets.all(0),
//                   onSelected: (value) {
//                     print(value);
//                   },
//                   itemBuilder: (BuildContext contesxt) {
//                     return [
//                       const PopupMenuItem(
//                         child: Text("View Contact"),
//                         value: "View Contact",
//                       ),
//                       const PopupMenuItem(
//                         child: Text("Media, links, and docs"),
//                         value: "Media, links, and docs",
//                       ),
//                       const PopupMenuItem(
//                         child: Text("Whatsapp Web"),
//                         value: "Whatsapp Web",
//                       ),
//                       const PopupMenuItem(
//                         child: Text("Search"),
//                         value: "Search",
//                       ),
//                       const PopupMenuItem(
//                         child: Text("Mute Notification"),
//                         value: "Mute Notification",
//                       ),
//                       const PopupMenuItem(
//                         child: Text("Wallpaper"),
//                         value: "Wallpaper",
//                       ),
//                     ];
//                   },
//                 ),
//               ],
//             ),
//           ),
//           body: Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             child: WillPopScope(
//               child: Column(
//                 children: [
//                   Expanded(
//                     // height: MediaQuery.of(context).size.height - 150,
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       controller: _scrollController,
//                       itemCount: messages.length + 1,
//                       itemBuilder: (context, index) {
//                         if (index == messages.length) {
//                           return Container(
//                             height: 70,
//                           );
//                         }
//                         // if (messages[index].type == "source") {
//                         //   return OwnMessageCard(
//                         //     message: messages[index].message,
//                         //     time: messages[index].time,
//                         //   );
//                         // } else {
//                         //   return ReplyCard(
//                         //     message: messages[index].message,
//                         //     time: messages[index].time,
//                         //   );
//                         // }
//                       },
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Container(
//                       height: 70,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: MediaQuery.of(context).size.width - 60,
//                                 child: Card(
//                                   margin: const EdgeInsets.only(
//                                       left: 2, right: 2, bottom: 8),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(25),
//                                   ),
//                                   child: TextFormField(
//                                     controller: _controller,
//                                     focusNode: focusNode,
//                                     textAlignVertical: TextAlignVertical.center,
//                                     keyboardType: TextInputType.multiline,
//                                     maxLines: 5,
//                                     minLines: 1,
//                                     onChanged: (value) {
//                                       if (value.length > 0) {
//                                         setState(() {
//                                           sendButton = true;
//                                         });
//                                       } else {
//                                         setState(() {
//                                           sendButton = false;
//                                         });
//                                       }
//                                     },
//                                     decoration: InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: "Type a message",
//                                       hintStyle: const TextStyle(color: Colors.grey),
//                                       prefixIcon: IconButton(
//                                         icon: Icon(
//                                           show
//                                               ? Icons.keyboard
//                                               : Icons.emoji_emotions_outlined,
//                                         ),
//                                         onPressed: () {
//                                           if (!show) {
//                                             focusNode.unfocus();
//                                             focusNode.canRequestFocus = false;
//                                           }
//                                           setState(() {
//                                             show = !show;
//                                           });
//                                         },
//                                       ),
//                                       suffixIcon: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           IconButton(
//                                             icon: const Icon(Icons.attach_file),
//                                             onPressed: () {
//                                               showModalBottomSheet(
//                                                   backgroundColor:
//                                                       Colors.transparent,
//                                                   context: context,
//                                                   builder: (builder) =>
//                                                       bottomSheet());
//                                             },
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(Icons.camera_alt),
//                                             onPressed: () {
//                                               // Navigator.push(
//                                               //     context,
//                                               //     MaterialPageRoute(
//                                               //         builder: (builder) =>
//                                               //             CameraApp()));
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                       contentPadding: const EdgeInsets.all(5),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(
//                                   bottom: 8,
//                                   right: 2,
//                                   left: 2,
//                                 ),
//                                 child: CircleAvatar(
//                                   radius: 25,
//                                   backgroundColor: const Color(0xFF128C7E),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       sendButton ? Icons.send : Icons.mic,
//                                       color: Colors.white,
//                                     ),
//                                     onPressed: () {
//                                       // if (sendButton) {
//                                       //   _scrollController.animateTo(
//                                       //       _scrollController
//                                       //           .position.maxScrollExtent,
//                                       //       duration:
//                                       //           Duration(milliseconds: 300),
//                                       //       curve: Curves.easeOut);
//                                       //   sendMessage(
//                                       //       _controller.text,
//                                       //       widget.sourchat.id,
//                                       //       widget.chatModel.id);
//                                       //   _controller.clear();
//                                       //   setState(() {
//                                       //     sendButton = false;
//                                       //   });
//                                       // }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Container(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               onWillPop: () {
//                 if (show) {
//                   setState(() {
//                     show = false;
//                   });
//                 } else {
//                   Navigator.pop(context);
//                 }
//                 return Future.value(false);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget bottomSheet() {
//     return Container(
//       height: 278,
//       width: MediaQuery.of(context).size.width,
//       child: Card(
//         margin: const EdgeInsets.all(18.0),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   iconCreation(
//                       Icons.insert_drive_file, Colors.indigo, "Document"),
//                   const SizedBox(
//                     width: 40,
//                   ),
//                   iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
//                   const SizedBox(
//                     width: 40,
//                   ),
//                   iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
//                 ],
//               ),
//               const SizedBox(
//                 height: 30,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   iconCreation(Icons.headset, Colors.orange, "Audio"),
//                   const SizedBox(
//                     width: 40,
//                   ),
//                   iconCreation(Icons.location_pin, Colors.teal, "Location"),
//                   const SizedBox(
//                     width: 40,
//                   ),
//                   iconCreation(Icons.person, Colors.blue, "Contact"),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget iconCreation(IconData icons, Color color, String text) {
//     return InkWell(
//       onTap: () {},
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: color,
//             child: Icon(
//               icons,
//               // semanticLabel: "Help",
//               size: 29,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Text(
//             text,
//             style: const TextStyle(
//               fontSize: 12,
//               // fontWeight: FontWeight.w100,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }



// // this._currentUuid = _uuid.v4();
//   CallKitParams callKitParams = CallKitParams(
//     id: "12333444",
//     nameCaller: 'Hien Nguyen',
//     appName: 'Callkit',
//     avatar: 'https://i.pravatar.cc/100',
//     handle: '0123456789',
//     type: 0,
//     textAccept: 'Accept',
//     textDecline: 'Decline',
//     missedCallNotification: NotificationParams(
//       showNotification: true,
//       isShowCallback: true,
//       subtitle: 'Missed call',
//       callbackText: 'Call back',
//     ),

//     duration: 30000,
//     extra: <String, dynamic>{'userId': '1a2b3c4d'},
//     headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
//     android: const AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: false,
//         ringtonePath: 'system_ringtone_default',
//         backgroundColor: '#0955fa',
//         backgroundUrl: 'https://i.pravatar.cc/500',
//         actionColor: '#4CAF50',
//         incomingCallNotificationChannelName: "Incoming Call",
//         missedCallNotificationChannelName: "Missed Call"),
//     // ios: IOSParams(
//     //   iconName: 'CallKitLogo',
//     //   handleType: 'generic',
//     //   supportsVideo: true,
//     //   maximumCallGroups: 2,
//     //   maximumCallsPerCallGroup: 1,
//     //   audioSessionMode: 'default',
//     //   audioSessionActive: true,
//     //   audioSessionPreferredSampleRate: 44100.0,
//     //   audioSessionPreferredIOBufferDuration: 0.005,
//     //   supportsDTMF: true,
//     //   supportsHolding: true,
//     //   supportsGrouping: false,
//     //   supportsUngrouping: false,
//     //   ringtonePath: 'system_ringtone_default',
//     // ),
//   );