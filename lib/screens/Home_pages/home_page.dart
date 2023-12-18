import 'dart:ui';

import 'package:WhatsYapp/app_string/constants.dart';
import 'package:WhatsYapp/screens/Home_pages/home_page_call.dart';
import 'package:WhatsYapp/screens/Home_pages/home_page_chat.dart';
import 'package:WhatsYapp/screens/Home_pages/home_page_status.dart';
import 'package:WhatsYapp/screens/screen_settings.dart';
import 'package:WhatsYapp/widgets/widget_icon_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    // required this.chatmodels,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var subscription;
  bool isInternetLostDialogVisible = false; // Track the dialog visibility state

  @override
  void initState() {
    super.initState();
    
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        // Show the instant alert dialog when the internet is lost.
        if (!isInternetLostDialogVisible) {
          _showInternetLostDialog();
          isInternetLostDialogVisible = true;
        }
      } else {
        // Internet connection is back, hide the dialog if it's visible.
        if (isInternetLostDialogVisible) {
          Navigator.pop(context); // Close the dialog
          isInternetLostDialogVisible = false;
        }
      }
    });
  }

  @override
  void dispose() {
    // Don't cancel the subscription here to keep listening for connectivity changes.
    super.dispose();
  }

// Function to show the instant alert dialog for internet loss.
  void _showInternetLostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            contentPadding: EdgeInsets.all(8.0),
            title: const Text(''),
            content: Container(
              height: 130,
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/no-internet.png',
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "No Internet!",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Please check internet connection!"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // final List<ChatModel> chatmodels;
  Widget openPopUp() {
    return PopupMenuButton(
      itemBuilder: (context) {
        return List.generate(
            3,
            (index) => const PopupMenuItem(
                  child: Text('Setting'),
                ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // CustomIconButton(onPressed: () {}, icon: Icons.camera_alt),
            CustomIconButton(onPressed: () {}, icon: Icons.search),

            PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              itemBuilder: (context) {
                return [
                  // In this case, we need 5 popupmenuItems one for each option.
                  // const PopupMenuItem(child: Text('New Group')),
                  // const PopupMenuItem(child: Text('New Broadcast')),
                  // const PopupMenuItem(child: Text('Linked Devices')),
                  // const PopupMenuItem(child: Text('Starred Messages')),
                  PopupMenuItem(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: const Text('Settings')),
                ];
              },
            ),
          ],
          backgroundColor: const Color(0xFF017F6A),
          title: const Text(
            AppConstants.appName,
            style:
                TextStyle(letterSpacing: 1, fontSize: 23, color: Colors.white),
          ),
          elevation: 1,
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Text('CHATS', style: TextStyle(color: Colors.white)),
              ),
              // Tab(
              //   child: Text('STATUS', style: TextStyle(color: Colors.white)),
              // ),
              Tab(
                child: Text('CALLS', style: TextStyle(color: Colors.white)),
              ),
            ],
            labelColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            ChatHomePage(),
            //  StatusHomePage(),
            CallHomePage(),
          ],
        ),
      ),
    );
  }
}
 // ChatPagegit(
            //   chatmodels: const [],
            //   // sourchat: widget.
            // ),