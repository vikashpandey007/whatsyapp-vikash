import 'package:flutter/material.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/call_background.png',
            fit: BoxFit.cover,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Text(
                  'End-to_end encrypted',
                  style: TextStyle(
                      fontSize: 15,
                      // fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/user_image.jpg'),
                ),
                SizedBox(height: 25),
                Text(
                  'Whatsyapp',
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                //
                SizedBox(height: 20),
                Text(
                  'Ringing',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                // Row for call actions

                SizedBox(height: 20),

                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      color: Colors.grey[600],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              20.0), // Adjust the radius as needed
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
