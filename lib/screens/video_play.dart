import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('messages');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
      ),
      body: StreamBuilder(
        stream: _databaseReference.onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          Map<dynamic, dynamic> messages = snapshot.data!.snapshot.value;
          List<Widget> messageWidgets = [];

          if (messages != null) {
            messages.forEach((key, value) {
              String messageType = value['type'];
              String messageText = value['url'];

              if (messageType == 'video') {
                // Display video widget
                // You can use packages like video_player to display the video
                // Example: VideoPlayerController.network(messageText)
                messageWidgets.add(
                  VideoPlayerWidget(videoUrl: messageText),
                );
              }
            });
          }

          return ListView(
            children: messageWidgets,
          );
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    // Implement your video player widget here
    // Example: VideoPlayerController.network(videoUrl)
    return Container(
      child: Text('Video Player Widget: $videoUrl'),
    );
  }
}
