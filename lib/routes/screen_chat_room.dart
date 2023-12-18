import 'dart:io';

import 'package:WhatsYapp/Agora/AgoraAudioCall.dart';
import 'package:WhatsYapp/Agora/AgoraCall.dart';
import 'package:WhatsYapp/Agora/example.dart';
import 'package:WhatsYapp/AudioRecoder/AudioPlayer.dart';
import 'package:WhatsYapp/AudioRecoder/AudioRecoder.dart';
import 'package:WhatsYapp/AudioRecoder/AudioRecoderSound.dart';
import 'package:WhatsYapp/AudioRecoder/Playrecoding.dart';
import 'package:WhatsYapp/AudioRecoder/playAudioUrl.dart';
import 'package:WhatsYapp/dependencies/models/model.dart';
import 'package:WhatsYapp/dependencies/notification/send_fcm.dart';
import 'package:WhatsYapp/agoraTokenCreation/agoraTokenCreation.dart';
import 'package:WhatsYapp/widgets/widget_own_message.dart';
import 'package:WhatsYapp/widgets/widget_replay_message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class ScreenChatRoom extends StatefulWidget {
  var data;
  final user, client, profile;

  ScreenChatRoom(
      {super.key,
      required this.user,
      required this.client,
      this.data,
      this.profile});

  @override
  _ScreenChatRoomState createState() => _ScreenChatRoomState();
}

class _ScreenChatRoomState extends State<ScreenChatRoom> {
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  late final FirebaseAuth auth;
  late String imageUrl;
  List messages = [];
  File? imageCamera;
  File? document;
  File? videoFile;
  // bool isRecording = false;
  // late FlutterSoundRecorder _audioRecorder;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late DatabaseReference messages_ref, conversations_ref, userInfo_ref;
  ScrollController? hController;
  var temp = [];
  late VideoPlayerController _videoController;

  var profilePic;
  bool? showPlayer = false;
  bool? recording = false;
  AudioSource? audioSource;
  String? newpath;
  bool? progress;
  late DateTime lastUpdateTime;

  getUserInfo() {
    userInfo_ref = FirebaseDatabase.instance
        .ref()
        .child('Users/${auth.currentUser!.phoneNumber}/info');

    userInfo_ref.onValue.listen((event) async {
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        var valueMap = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          profilePic = valueMap['profile_picture'];
        });
      });
    });
  }

  getRecording(message) {
    return PlayerWidget(
      url: message["media_url"],
    );
  }

  void listenForNewChild() {
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference
        .child('Messages/${widget.user}_${widget.client}')
        .onChildAdded
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final timestamp = int.tryParse(data['timestamp']);
      final childTimestamp = DateTime.fromMillisecondsSinceEpoch(timestamp!);

      if (childTimestamp.isAfter(lastUpdateTime)) {
        print(data["receiver_id"]);
        print("New child : ${event.snapshot.key} => ${data}");
        // Update your UI or handle the data as needed

        // Update the last update time
        lastUpdateTime = DateTime.now();
      }
    });
  }

  // void listenForNewChild() {
  //   databaseReference.child('path/to/your/data').onChildAdded.listen((event) {
  //     final data = event.snapshot.value as Map;
  //     final childTimestamp =
  //         DateTime.fromMillisecondsSinceEpoch(data['timestamp']);

  //     if (childTimestamp.isAfter(lastUpdateTime)) {
  //       print("New child added: ${event.snapshot.key} => ${data['value']}");
  //       // Update your UI or handle the data as needed

  //       // Update the last update time
  //       lastUpdateTime = DateTime.now();
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    lastUpdateTime = DateTime.now();
    progress = false;
    showPlayer = false;
    recording = false;
    getUserInfo();

    conversations_ref = FirebaseDatabase.instance
        .ref()
        .child('Conversations/${widget.user}_${widget.client}');
    conversations_ref.child("unread_count_user").set(0);
    messages_ref = FirebaseDatabase.instance
        .ref()
        .child('Messages/${widget.user}_${widget.client}');
    _scrollbottom();
    _subscribeToNotifications();
    listenForNewChild();
  }

  void _scrollbottom() async {
    messages_ref.onValue.listen((event) {
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        var valueMap = event.snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          messages = valueMap.values.toList();
          messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
          // AudioPlayWithURL().playSound("asssest/recieve.mp3");
        });
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      _scrollController.addListener(() {});
    });
  }

  void _subscribeToNotifications() async {
    String user_without_plus = widget.user.replaceFirst('+', '');
    String client_without_plus = widget.client.replaceFirst('+', '');
    await FirebaseMessaging.instance
        .subscribeToTopic('${user_without_plus}_${client_without_plus}')
        .whenComplete(() => print('subscribe'));
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget listItemMessages({required messages}) {
    final duration =
        Moment.fromMillisecondsSinceEpoch(int.parse(messages['timestamp']))
            .format("HH:mm");

    bool isOwnMessage = messages["sender_id"] == auth.currentUser!.phoneNumber;

    Widget messageWidget;

    if (messages['type'] == 'image') {
      // Check if the media_url is not null or empty
      if (messages['media_url'] == null || messages['media_url'].isEmpty) {
        // Display a loader while the image is being fetched
        messageWidget =
            CircularProgressIndicator(); // Or any other loader widget
      } else {
        // Image message
        messageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            messages['media_url'],
            width:
                MediaQuery.of(context).size.width * 0.5, // 50% of screen width
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        );
      }
    } else if (messages['type'] == 'video') {
      // Video message handling
      VideoPlayerController _videoController =
          VideoPlayerController.networkUrl(Uri.parse('media_url'));

      // Removed the initialization check and directly returning the video player widget
      messageWidget = AspectRatio(
        aspectRatio: 16 / 9, // Default aspect ratio, adjust as needed
        child: VideoPlayer(_videoController),
      );

      _videoController.initialize().then((_) {
        // Update the UI when the video is initialized
        if (mounted) {
          setState(() {});
        }
      }).catchError((error) {
        // Handle video initialization error
        print("Error initializing video player: $error");
      });
    } else if (messages['type'] == 'Voice recording') {
      print(messages['type']);
      return getRecording(messages);
    } else {
      // Text message
      messageWidget = isOwnMessage
          ? OwnMessageCard(message: messages['text'], time: duration)
          : ReplyCard(message: messages['text'], time: duration);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          messageWidget,
          // Padding(
          //   padding: const EdgeInsets.only(top: 5),
          //   child: Text(duration,
          //       style: TextStyle(fontSize: 12, color: Colors.grey)),
          // ),
        ],
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFF017F6A),
          leadingWidth: 70,
          titleSpacing: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 24,
                ),
                CircleAvatar(
                  radius: 20,
                  // backgroundColor: Colors.blueGrey,
                  // child: Image.network(widget.data["client_pp"])
                  backgroundImage: NetworkImage(widget.profile),
                  // SvgPicture.asset(
                  //   "assets/person.svg",
                  //   color: Colors.white,
                  //   height: 36,
                  //   width: 36,
                  // ),
                ),
              ],
            ),
          ),
          title: InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.client,
                    style: TextStyle(
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    "last seen today at 12:05",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.videocam, color: Colors.white),
                onPressed: () async {
//                 \

                  String token = await AgoraTokenGenerator()
                      .buildTokenWithUid("${widget.user}_${widget.client}");
                  print(token);

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgoraVideoCall(
                          user: widget.user,
                          client: widget.client,
                          client_profile: widget.profile,
                          token: token,
                          user_profile: profilePic,
                          channnelId: "${widget.user}_${widget.client}",
                        ),
                      ));
                }),
            IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: () async {
                  String token = await AgoraTokenGenerator()
                      .buildTokenWithUid("${widget.user}_${widget.client}");
                  print(token);

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgoracallpageAudio(
                          user: widget.user,
                          client: widget.client,
                          client_profile: widget.profile,
                          token: token,
                          user_profile: profilePic,
                          channelId: "${widget.user}_${widget.client}",
                        ),
                      ));
                  // await Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => CallInvitation(),
                  //     ));
                }),
            PopupMenuButton<String>(
              color: Colors.white,
              padding: const EdgeInsets.all(0),
              onSelected: (value) {
                print(value);
              },
              itemBuilder: (BuildContext contesxt) {
                return [];
                // return [
                //   const PopupMenuItem(
                //     child: Text("View Contact"),
                //     value: "View Contact",
                //   ),
                //   const PopupMenuItem(
                //     child: Text("Media, links, and docs"),
                //     value: "Media, links, and docs",
                //   ),
                //   const PopupMenuItem(
                //     child: Text("Whatsapp Web"),
                //     value: "Whatsapp Web",
                //   ),
                //   const PopupMenuItem(
                //     child: Text("Search"),
                //     value: "Search",
                //   ),
                //   const PopupMenuItem(
                //     child: Text("Mute Notification"),
                //     value: "Mute Notification",
                //   ),
                //   const PopupMenuItem(
                //     child: Text("Wallpaper"),
                //     value: "Wallpaper",
                //   ),
                // ];
              },
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/whatsapp_Back.png',
            fit: BoxFit.cover,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, int index) {
                      return listItemMessages(messages: messages[index]);
                    },
                  ),
                ),
                recording == false
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 70,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 60,
                                    child: Card(
                                      margin: const EdgeInsets.only(
                                          left: 2, right: 2, bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: TextFormField(
                                        controller: _controller,
                                        focusNode: focusNode,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 5,
                                        minLines: 1,
                                        onChanged: (value) {
                                          if (value.length > 0) {
                                            setState(() {
                                              sendButton = true;
                                            });
                                          } else {
                                            setState(() {
                                              sendButton = false;
                                            });
                                          }
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Type a message",
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          prefixIcon: IconButton(
                                            icon: Icon(
                                                show
                                                    ? Icons.keyboard
                                                    : Icons
                                                        .emoji_emotions_outlined,
                                                color: Colors.grey),
                                            onPressed: () {
                                              if (!show) {
                                                focusNode.unfocus();
                                                focusNode.canRequestFocus =
                                                    false;
                                              }
                                              setState(() {
                                                show = !show;
                                              });
                                            },
                                          ),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.attach_file,
                                                    color: Colors.grey),
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (builder) =>
                                                          bottomSheet());
                                                },
                                              ),
                                              sendButton
                                                  ? Container()
                                                  : IconButton(
                                                      icon: Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        ImageFromCamera();
                                                        //   Navigator.pop(context);
                                                      },
                                                    )
                                            ],
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8,
                                      right: 2,
                                      left: 2,
                                    ),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: const Color(0xFF128C7E),
                                      child: IconButton(
                                        icon: Icon(
                                          sendButton ? Icons.send : Icons.mic,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          if (sendButton) {
                                            sendMessage(
                                              _controller.text,
                                            );

                                            _controller.clear();

                                            setState(() {
                                              sendButton = false;
                                            });
                                          } else {
                                            setState(() {
                                              recording = true;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        height: 150,
                        width: width * 0.947,
                        decoration: BoxDecoration(
                            color: Color(0xfffafafa),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            )),
                        child: showPlayer as bool
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: AudioPlayerClass(
                                    source: audioSource!,
                                    url: newpath,
                                    onDelete: () {
                                      setState(() {
                                        showPlayer = false;
                                        recording = false;
                                      });
                                    },
                                    send: (url) async {
                                      print("url == $url");

                                      await sendRecordingMessage(url);

                                      setState(() {
                                        showPlayer = false;
                                        recording = false;
                                      });
                                    }),
                              )
                            : AudioRecorderSoundClass(
                                onStop: (path) {
                                  setState(() {
                                    print(path);
                                    audioSource =
                                        AudioSource.uri(Uri.parse(path));
                                    newpath = path;
                                    showPlayer = true;
                                  });
                                },
                              ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendRecordingMessage(
    url,
  ) async {
    // String user_without_plus = widget.user.replaceFirst('+', '');
    // String client_without_plus = widget.client.replaceFirst('+', '');

    // SendFCM().sendFcmMessage("${user_without_plus}_${client_without_plus}",
    //     auth.currentUser!.phoneNumber.toString(), text);

    DatabaseReference push_key = messages_ref.push();
    try {
      await push_key.set({
        'file_name': 'mp4 audio',
        'media_url': url,
        //  'read_status': 'false',
        'receiver_id': widget.client,
        'sender_id': auth.currentUser!.phoneNumber,
        'text': "",
        'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
        'type': "Voice recording",
      });

      await conversations_ref.update({
        'client': widget.client,
        'created_at': (Moment.now().millisecondsSinceEpoch).toString(),
        'last_message': push_key.key,
        'last_message_sender_id': widget.client,
        'last_message_text': "Voice recording",
        'last_message_timestamp':
            (Moment.now().millisecondsSinceEpoch).toString(),
        'user_pp': profilePic,
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

  sendMessage(
    text,
  ) async {
    String user_without_plus = widget.user.replaceFirst('+', '');
    String client_without_plus = widget.client.replaceFirst('+', '');

    SendFCM().sendFcmMessage("${user_without_plus}_${client_without_plus}",
        auth.currentUser!.phoneNumber.toString(), text);

    DatabaseReference push_key = messages_ref.push();
    try {
      await push_key.set({
        'file_name': 'mama.pdf',
        'media_url': "https://example.com/path/to/file.pdf",
        //  'read_status': 'false',
        'receiver_id': widget.client,
        'sender_id': auth.currentUser!.phoneNumber,
        'text': text,
        'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
        'type': "text",
      });

      await conversations_ref.update({
        'client': widget.client,
        'created_at': (Moment.now().millisecondsSinceEpoch).toString(),
        'last_message': push_key.key,
        'last_message_sender_id': widget.client,
        'last_message_text': text,
        'last_message_timestamp':
            (Moment.now().millisecondsSinceEpoch).toString(),
        'user_pp': profilePic,
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

  Future<void> ImageFromCamera() async {
    print("pickImageFromCamera called");
    // Navigator.pop(context);

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Upload image to Firebase Storage
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance.ref().child(
              '/Conversations/conversation_id/$imageName${Moment.now().millisecondsSinceEpoch}.jpg',
            );
        UploadTask uploadTask = storageReference.putFile(imageFile);
        TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});

        // Get the download URL
        String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
        DatabaseReference push_key_camera = messages_ref.push();

        // Save the download URL to Firebase Realtime Database
        DatabaseReference databaseReference = FirebaseDatabase.instance
            .ref()
            .child('Messages/${widget.user}_${widget.client}');
        push_key_camera.set({
          'file_name': 'mama.pdf',
          //   'read_status': 'false',
          'receiver_id': widget.client,
          'sender_id': auth.currentUser!.phoneNumber,
          "text": "",
          'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
          'type': "image",
          "media_url": downloadUrl,
          // Add any other data you want to save along with the image
        });

        conversations_ref.update({
          'client': widget.client,
          'created_at': (Moment.now().millisecondsSinceEpoch).toString(),
          'last_message': push_key_camera.key,
          'last_message_sender_id': widget.client,
          'last_message_text': '',
          'last_message_timestamp':
              (Moment.now().millisecondsSinceEpoch).toString(),
          'profile_picture': widget.data["profile_picture"],
          'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
          'unread_count_client': ServerValue.increment(1),
          'user': widget.user,
        });

        setState(() {
          imageCamera = imageFile;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> DocumentFromGallery() async {
    print("pickDocumentFromGallery called");
    Navigator.pop(context);

    try {
      // Use File Picker to pick a document of any file type
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.any, // Allows all file types
      );

      if (pickedFile != null) {
        File documentFile = File(pickedFile.files.single.path!);

        // Upload document to Firebase Storage
        String documentName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance.ref().child(
              '$documentName.${pickedFile.files.single.extension}',
            );
        UploadTask uploadTask = storageReference.putFile(documentFile);
        TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});

        // Get the download URL
        String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
        DatabaseReference push_key_document = messages_ref.push();

        // Save the download URL to Firebase Realtime Database
        DatabaseReference databaseReference = FirebaseDatabase.instance
            .ref()
            .child('Messages/${widget.user}_${widget.client}');
        push_key_document.set({
          'file_name': pickedFile.files.single.name,
          'receiver_id': widget.client,
          'sender_id': auth.currentUser!.phoneNumber,
          'timestamp': (DateTime.now().millisecondsSinceEpoch).toString(),
          'type': "document",
          'media_url': downloadUrl,
          // Add any other data you want to save along with the document
        });

        conversations_ref.update({
          'client': widget.client,
          'created_at': (Moment.now().millisecondsSinceEpoch).toString(),
          'last_message': push_key_document.key,
          'last_message_sender_id': widget.client,
          'last_message_text': '',
          'last_message_timestamp':
              (Moment.now().millisecondsSinceEpoch).toString(),
          'profile_picture': widget.data["profile_picture"],
          'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
          'unread_count_client': ServerValue.increment(1),
          'user': widget.user,
        });

        setState(() {
          document = documentFile;
        });
      }
    } catch (e) {
      print("Error picking document: $e");
    }
  }

  Future<void> ImageFromGallery() async {
    print("pickmageFromGallery called");
    Navigator.pop(context);

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Upload image to Firebase Storage
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance.ref().child(
              '/Conversations/conversation_id/$imageName${Moment.now().millisecondsSinceEpoch}.jpg',
            );
        UploadTask uploadTask = storageReference.putFile(imageFile);
        TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});

        // Get the download URL
        String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
        DatabaseReference push_key_image = messages_ref.push();

        // Save the download URL to Firebase Realtime Database
        DatabaseReference databaseReference = FirebaseDatabase.instance
            .ref()
            .child('Messages/${widget.user}_${widget.client}');
        push_key_image.set({
          'file_name': 'mama.pdf',
          //   'read_status': 'false',
          'receiver_id': widget.client,
          'sender_id': auth.currentUser!.phoneNumber,
          "text": "",
          'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
          'type': "image",

          "media_url": downloadUrl,
          // Add any other data you want to save along with the image
        });

        conversations_ref.update({
          'client': widget.client,
          'created_at': (Moment.now().millisecondsSinceEpoch).toString(),
          'last_message': push_key_image.key,
          'last_message_sender_id': widget.client,
          'last_message_text': '',
          'last_message_timestamp':
              (Moment.now().millisecondsSinceEpoch).toString(),
          'profile_picture': widget.data["profile_picture"],
          'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
          'unread_count_client': ServerValue.increment(1),
          'user': widget.user,
        });

        setState(() {
          imageCamera = imageFile;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> VideoFromGallery() async {
    print("pickVideoFromGallery called");
    Navigator.pop(context);

    try {
      final pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        videoFile = File(pickedFile.path);

        // Upload video to Firebase Storage
        String videoName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance.ref().child(
              '/Conversations/conversation_id/$videoName${Moment.now().millisecondsSinceEpoch}.mp4',
            );
        UploadTask uploadTask = storageReference.putFile(videoFile!);
        TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});

        // Get the download URL
        String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
        DatabaseReference push_key_video = messages_ref.push();

        // Save the download URL to Firebase Realtime Database
        DatabaseReference databaseReference = FirebaseDatabase.instance
            .ref()
            .child('Messages/${widget.user}_${widget.client}');
        push_key_video.set({
          'file_name': 'mama.pdf',
          //  'read_status': 'false',
          'receiver_id': widget.client,
          'sender_id': auth.currentUser!.phoneNumber,
          'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
          'type': "video",
          'media_url': downloadUrl,
          // Add any other data you want to save along with the video
        });

        conversations_ref.update({
          'client': widget.client,
          'created_at': (Moment.now().millisecondsSinceEpoch).toString(),
          'last_message': push_key_video.key,
          'last_message_sender_id': widget.client,
          'last_message_text': '',
          'last_message_timestamp':
              (Moment.now().millisecondsSinceEpoch).toString(),
          'profile_picture': widget.data["profile_picture"],
          'timestamp': (Moment.now().millisecondsSinceEpoch).toString(),
          'unread_count_client': ServerValue.increment(1),
          'user': widget.user,
        });

        setState(() {
          videoFile = videoFile;
        });
      }
    } catch (e) {
      print("Error picking video: $e");
    }
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document", () {
                    DocumentFromGallery();
                  }),
                  const SizedBox(
                    width: 40,
                  ),
                  GestureDetector(
                    onTap: ImageFromCamera,
                    child: iconCreation(Icons.camera_alt, Colors.pink, "Camera",
                        () {
                      ImageFromCamera();
                    }),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery",
                      () {
                    ImageFromGallery();
                  }),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio", () {}),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.video_file, Colors.teal, "Video", () {
                    VideoFromGallery();
                  }),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact", () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(
      IconData icons, Color color, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    messages_ref.onDisconnect();
    conversations_ref.onDisconnect();
    userInfo_ref.onDisconnect();

    // _audioRecorder.closeAudioSession();
    super.dispose();
  }
}
