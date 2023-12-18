import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            SizedBox(height: 50),
            Text(
              'End-to_end encrypted',
              style: TextStyle(
                  fontSize: 15,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            // Video streaming view
            SizedBox(height: 25),
            Text(
              'Whatsyapp',
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            //
            SizedBox(height: 20),
            Text(
              'Ringing',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Center(
              child:
                  Placeholder(), // Replace with actual video streaming widget
            ),

            // Controls overlay
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
                          Icons.speaker,
                        ),
                        iconSize: 32,
                        onPressed: () {
                          // Add speaker button functionality
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.videocam),
                        iconSize: 32,
                        onPressed: () {
                          // Add video button functionality
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.mic),
                        iconSize: 32,
                        onPressed: () {
                          // Add mute button functionality
                        },
                        color: Colors.white,
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.call_end),
                          iconSize: 30,
                          onPressed: () {
                            // Add end call button functionality
                          },
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
  }
}
