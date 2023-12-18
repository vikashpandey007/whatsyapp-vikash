import 'dart:async';

import 'package:WhatsYapp/routes/screen_chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uni_links/uni_links.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with WidgetsBindingObserver {
  late final FirebaseAuth auth;
  StreamSubscription? _sub;
  String _uniqueId = '';

  late DatabaseReference client_ref,
      search_ref,
      conversation_message,
      last_seen;
  var clientNumber, profilePic;
  List messages = [];

  Widget listItem({
    required Map conversations,
  }) {
    final duration = Moment.fromMillisecondsSinceEpoch(
            int.parse(conversations['last_message_timestamp']))
        .fromNow();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenChatRoom(
              data: conversations,
              profile: conversations['client_pp'],
              user: conversations['user'],
              client: conversations["client"],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27.0,
              backgroundImage: NetworkImage(conversations['client_pp']),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversations['client'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      conversations['unread_count_user'] == 0
                          ? Icon(Icons.done_all, color: Colors.blue, size: 18)
                          : Icon(Icons.done_all, color: Colors.grey, size: 18),
                      SizedBox(width: 10),
                      Text(
                        conversations['last_message_text'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                conversations['unread_count_user'] != 0
                    ? Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              conversations['unread_count_user'].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ))
                    : Container(),
                Text(
                  duration,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String? link) {
      if (link != null) {
        Uri uri = Uri.parse(link);

        setState(() {
          _uniqueId = uri.pathSegments.last;

          client_ref.onValue.listen((event) {
            print(event.snapshot.value);
            // Handle the real-time data update
            event.snapshot.children.forEach((DataSnapshot snapshot) {
              //  print(snapshot.children.);
              var valueMap = event.snapshot.value as Map<dynamic, dynamic>;
              var profilePic = valueMap['profile_picture'];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenChatRoom(
                    profile: profilePic,
                    user: auth.currentUser!.phoneNumber,
                    client: _uniqueId,
                  ),
                ),
              );
            });
          });
        });
      }
    }, onError: (err) {
      // Handle exception
    });

    // Handle initial link
    String? initialLink = await getInitialLink();
    if (initialLink != null) {
      Uri uri = Uri.parse(initialLink);
      setState(() {
        _uniqueId = uri.pathSegments.last;

        final client_ref =
            FirebaseDatabase.instance.ref().child('Clients/${_uniqueId}/info');

        client_ref.onValue.listen((event) {
          print(event.snapshot.value);
          // Handle the real-time data update
          event.snapshot.children.forEach((DataSnapshot snapshot) {
            //  print(snapshot.children.);
            var valueMap = event.snapshot.value as Map<dynamic, dynamic>;
            var profilePic = valueMap['profile_picture'];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScreenChatRoom(
                  profile: profilePic,
                  user: auth.currentUser!.phoneNumber,
                  client: _uniqueId,
                ),
              ),
            );
          });
        });
      });
    }
  }

  final databaseReference = FirebaseDatabase.instance.reference();
  TextEditingController phoneNumberController = TextEditingController();
  String searchResult = '';

  void searchForClient(String phoneNumber) async {
    final search_ref = await FirebaseDatabase.instance
        .ref()
        .child('Clients/+91${phoneNumber}/info');

    search_ref.onValue.listen((event) async {
      print(event.snapshot.value);
      if (event.snapshot.value != null) {
        event.snapshot.children.forEach((DataSnapshot snapshot) {
          var valueMap = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            clientNumber = valueMap['number'];

            profilePic = valueMap['profile_picture'];
          });
        });

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenChatRoom(
              profile: profilePic,
              user: auth.currentUser!.phoneNumber,
              client: clientNumber,
            ),
          ),
        );
      } else {
        print("client not found");
      }
    });
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search for Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(labelText: 'Enter Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (phoneNumberController.text.isNotEmpty) {
                    Navigator.pop(context);
                    searchForClient(phoneNumberController.text);
                  } else {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Please enter phone number",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                child: Text('Search'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _conversation_Ref() async {
    conversation_message
        .orderByChild("user")
        .equalTo(auth.currentUser!.phoneNumber)
        .onValue
        .listen((event) {
      // Handle the real-time data update
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        var valueMap = event.snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          messages = valueMap.values.toList();
          messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        });
      });
    });
  }

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

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    last_seen = FirebaseDatabase.instance
        .ref()
        .child('Last Seen')
        .child(auth.currentUser!.phoneNumber.toString());
    conversation_message =
        FirebaseDatabase.instance.ref().child('Conversations');

    client_ref =
        FirebaseDatabase.instance.ref().child('Clients/${_uniqueId}/info');
    initUniLinks();
    _conversation_Ref();

    WidgetsBinding.instance.addObserver(this);
    // FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) async {
    super.didChangeAppLifecycleState(
      state,
    );
    if (state == AppLifecycleState.paused) {
      print("===== pushed");
    } else if (state == AppLifecycleState.resumed) {
      print('===== app resumed');
      last_seen.set("online");
    } else if (state == AppLifecycleState.inactive) {
      print('===== app inactive');
      last_seen.set((Moment.now().millisecondsSinceEpoch).toString());
    } else if (state == AppLifecycleState.detached) {
      print('===== app detached');
      last_seen.set((Moment.now().millisecondsSinceEpoch).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF017F6A),
          child: Icon(
            Icons.chat,
            color: Colors.white,
          ),
          onPressed: () {
            showSearchDialog(context);
          }),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.white,
                      child: listItem(conversations: messages[index]),
                    );
                  }))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    client_ref.onDisconnect();
    WidgetsBinding.instance.removeObserver(this);

    conversation_message.onDisconnect();
    super.dispose();
  }
}
